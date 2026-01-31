//
//  PokemonListViewController.swift
//  PokeDex
//
//  Created by Hwangseokbeom on 1/31/26.
//

import UIKit

final class PokemonListViewController: UIViewController {

    private let viewModel: PokemonListViewModelInput & PokemonListViewModelOutput

    // MARK: - UI

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .mainRed
        cv.alwaysBounceVertical = true
        cv.dataSource = self
        cv.delegate = self
        cv.register(PokemonListCell.self, forCellWithReuseIdentifier: PokemonListCell.reuseID)
        return cv
    }()

    private let loadingIndicator: UIActivityIndicatorView = {
        let v = UIActivityIndicatorView(style: .large)
        v.hidesWhenStopped = true
        v.color = .white
        return v
    }()

    private lazy var refreshControl: UIRefreshControl = {
        let rc = UIRefreshControl()
        rc.tintColor = .white
        rc.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        return rc
    }()

    // MARK: - Init

    init(viewModel: some PokemonListViewModelInput & PokemonListViewModelOutput) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "도감"
        navigationItem.largeTitleDisplayMode = .never

        view.backgroundColor = .mainRed

        setupLayout()
        bindViewModel()
        viewModel.loadInitial()
    }

    private func setupLayout() {
        view.addSubview(collectionView)
        view.addSubview(loadingIndicator)

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false

        collectionView.refreshControl = refreshControl

        NSLayoutConstraint.activate([
            // 네비게이션바 아래부터 시작 (safeArea 기준)
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func bindViewModel() {
        viewModel.onUpdate = { [weak self] in
            DispatchQueue.main.async {
                guard let self else { return }

                self.collectionView.reloadData()

                if self.viewModel.isRefreshing == false {
                    self.refreshControl.endRefreshing()
                }

                if self.viewModel.isLoading {
                    self.loadingIndicator.startAnimating()
                } else {
                    self.loadingIndicator.stopAnimating()
                }
            }
        }

        viewModel.onError = { [weak self] message in
            DispatchQueue.main.async {
                guard let self else { return }
                self.refreshControl.endRefreshing()
                self.loadingIndicator.stopAnimating()
                self.showAlert(title: "오류", message: message)
            }
        }

        viewModel.onNavigateToDetail = { [weak self] pokemonID in
            DispatchQueue.main.async {
                guard let self else { return }
                let detailVC = DIContainer.shared.makePokemonDetailViewController(id: pokemonID)
                self.navigationController?.pushViewController(detailVC, animated: true)
            }
        }
    }

    @objc private func didPullToRefresh() {
        viewModel.refresh()
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UICollectionViewDataSource

extension PokemonListViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.items.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PokemonListCell.reuseID,
            for: indexPath
        ) as? PokemonListCell else {
            return UICollectionViewCell()
        }

        let model = viewModel.items[indexPath.item]
        cell.configure(imageURL: model.imageURL)

        // pagination trigger
        viewModel.loadNextPageIfNeeded(currentIndex: indexPath.item)

        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension PokemonListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.selectItem(at: indexPath.item)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension PokemonListViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {

        // 3열
        let columns: CGFloat = 3
        let inset: CGFloat = 16
        let spacing: CGFloat = 12

        let totalSpacing = (inset * 2) + (spacing * (columns - 1))
        let available = collectionView.bounds.width - totalSpacing
        let width = floor(available / columns)

        // 정사각형
        return CGSize(width: width, height: width)
    }
}
