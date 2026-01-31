//
//  PokemonDetailViewController.swift
//  PokeDex
//
//  Created by Hwangseokbeom on 1/31/26.
//

import UIKit

final class PokemonDetailViewController: UIViewController {

    private let viewModel: PokemonDetailViewModelInput & PokemonDetailViewModelOutput

    // MARK: - UI

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let imageView: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFit
        v.clipsToBounds = true
        v.backgroundColor = .systemGray6
        v.layer.cornerRadius = 16
        return v
    }()

    private let numberLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 18, weight: .semibold)
        l.textColor = .secondaryLabel
        return l
    }()

    private let nameLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 28, weight: .bold)
        l.textColor = .label
        l.numberOfLines = 1
        return l
    }()

    private let typeTitleLabel: UILabel = {
        let l = UILabel()
        l.text = "타입"
        l.font = .systemFont(ofSize: 16, weight: .semibold)
        l.textColor = .secondaryLabel
        return l
    }()

    private let typeValueLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 18, weight: .medium)
        l.textColor = .label
        l.numberOfLines = 0
        return l
    }()

    private let heightTitleLabel: UILabel = {
        let l = UILabel()
        l.text = "키"
        l.font = .systemFont(ofSize: 16, weight: .semibold)
        l.textColor = .secondaryLabel
        return l
    }()

    private let heightValueLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 18, weight: .medium)
        l.textColor = .label
        return l
    }()

    private let weightTitleLabel: UILabel = {
        let l = UILabel()
        l.text = "몸무게"
        l.font = .systemFont(ofSize: 16, weight: .semibold)
        l.textColor = .secondaryLabel
        return l
    }()

    private let weightValueLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 18, weight: .medium)
        l.textColor = .label
        return l
    }()

    private let loadingIndicator: UIActivityIndicatorView = {
        let v = UIActivityIndicatorView(style: .large)
        v.hidesWhenStopped = true
        return v
    }()

    private lazy var typeStack = makeRow(title: typeTitleLabel, value: typeValueLabel)
    private lazy var heightStack = makeRow(title: heightTitleLabel, value: heightValueLabel)
    private lazy var weightStack = makeRow(title: weightTitleLabel, value: weightValueLabel)

    // MARK: - Init

    init(viewModel: some PokemonDetailViewModelInput & PokemonDetailViewModelOutput) {
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
        view.backgroundColor = .systemBackground

        setupLayout()
        bindViewModel()
        viewModel.load()
    }

    // MARK: - Bind

    private func bindViewModel() {
        viewModel.onUpdate = { [weak self] in
            self?.render()
        }

        viewModel.onLoadingChange = { [weak self] isLoading in
            guard let self else { return }
            if isLoading {
                self.loadingIndicator.startAnimating()
            } else {
                self.loadingIndicator.stopAnimating()
            }
        }

        viewModel.onError = { [weak self] message in
            self?.showAlert(title: "오류", message: message)
        }
    }

    // MARK: - Render

    private func render() {
        guard let detail = viewModel.detail else { return }

        navigationItem.title = detail.koreanName

        numberLabel.text = "#\(detail.id)"
        nameLabel.text = detail.koreanName
        typeValueLabel.text = detail.types.map(\.displayName).joined(separator: " / ")
        heightValueLabel.text = String(format: "%.1f m", detail.heightMeters)
        weightValueLabel.text = String(format: "%.1f kg", detail.weightKg)

        let urlString = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(detail.id).png"
        if let url = URL(string: urlString) {
            loadImage(url: url)
        }
    }

    // MARK: - Layout

    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false

        let headerStack = UIStackView(arrangedSubviews: [numberLabel, nameLabel])
        headerStack.axis = .vertical
        headerStack.spacing = 6
        headerStack.translatesAutoresizingMaskIntoConstraints = false

        let mainStack = UIStackView(arrangedSubviews: [
            imageView,
            headerStack,
            typeStack,
            heightStack,
            weightStack
        ])
        mainStack.axis = .vertical
        mainStack.spacing = 16
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(mainStack)
        view.addSubview(loadingIndicator)
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),

            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),

            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    private func makeRow(title: UILabel, value: UILabel) -> UIStackView {
        let row = UIStackView(arrangedSubviews: [title, value])
        row.axis = .horizontal
        row.alignment = .top
        row.spacing = 16

        title.setContentHuggingPriority(.required, for: .horizontal)
        title.setContentCompressionResistancePriority(.required, for: .horizontal)

        return row
    }

    // MARK: - Image Loading

    private func loadImage(url: URL) {
        if let cached = ImageCache.shared.image(for: url) {
            imageView.image = cached
            return
        }

        Task { [weak self] in
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                guard let image = UIImage(data: data) else { return }
                ImageCache.shared.store(image: image, for: url)
                await MainActor.run { self?.imageView.image = image }
            } catch {
                // 이미지 로드는 치명적이지 않으므로 조용히 무시
            }
        }
    }

    // MARK: - Alert

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - Simple Image Cache

final class ImageCache {
    static let shared = ImageCache()
    private init() {}

    private var storage: [URL: UIImage] = [:]
    private let lock = NSLock()

    func image(for url: URL) -> UIImage? {
        lock.lock(); defer { lock.unlock() }
        return storage[url]
    }

    func store(image: UIImage, for url: URL) {
        lock.lock(); defer { lock.unlock() }
        storage[url] = image
    }
}
