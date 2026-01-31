//
//  PokemonListViewModel.swift
//  PokeDex
//
//  Created by Hwangseokbeom on 1/31/26.
//

import Foundation

// MARK: - Protocols

protocol PokemonListViewModelInput: AnyObject {
    func loadInitial()
    func loadNextPageIfNeeded(currentIndex: Int)
    func selectItem(at index: Int)
    func refresh()
}

protocol PokemonListViewModelOutput: AnyObject {
    var items: [PokemonSummary] { get }
    var isLoading: Bool { get }
    var isRefreshing: Bool { get }

    var onUpdate: (() -> Void)? { get set }
    var onError: ((String) -> Void)? { get set }
    var onNavigateToDetail: ((Int) -> Void)? { get set } // pokemonID
}

// MARK: - ViewModel

final class PokemonListViewModel: PokemonListViewModelInput, PokemonListViewModelOutput {

    // MARK: Output

    private(set) var items: [PokemonSummary] = [] {
        didSet { onUpdate?() }
    }

    private(set) var isLoading: Bool = false {
        didSet { onUpdate?() }
    }

    private(set) var isRefreshing: Bool = false {
        didSet { onUpdate?() }
    }

    var onUpdate: (() -> Void)?
    var onError: ((String) -> Void)?
    var onNavigateToDetail: ((Int) -> Void)?

    // MARK: Dependencies

    private let fetchListUseCase: FetchPokemonListUseCasing

    // MARK: Paging State

    private var limit: Int
    private var nextOffset: Int? = 0
    private var totalCount: Int = 0
    private var isRequesting: Bool = false

    // MARK: Init

    init(
        fetchListUseCase: FetchPokemonListUseCasing,
        limit: Int = 30
    ) {
        self.fetchListUseCase = fetchListUseCase
        self.limit = limit
    }

    // MARK: Input

    func loadInitial() {
        guard items.isEmpty else { return }
        fetchPage(offset: 0, isRefresh: false)
    }

    func refresh() {
        fetchPage(offset: 0, isRefresh: true)
    }

    func loadNextPageIfNeeded(currentIndex: Int) {
        // 이미 요청 중이면 무시
        guard !isRequesting else { return }

        // 다음 페이지가 없으면 종료
        guard let offset = nextOffset else { return }

        // 끝에서 6개 남았을 때 다음 페이지 요청
        let thresholdIndex = max(0, items.count - 6)
        guard currentIndex >= thresholdIndex else { return }

        fetchPage(offset: offset, isRefresh: false)
    }

    func selectItem(at index: Int) {
        guard items.indices.contains(index) else { return }
        let id = items[index].id
        onNavigateToDetail?(id)
    }

    // MARK: Fetch

    private func fetchPage(offset: Int, isRefresh: Bool) {
        isRequesting = true

        if isRefresh {
            isRefreshing = true
        } else {
            isLoading = true
        }

        Task { [weak self] in
            guard let self else { return }
            do {
                let page = try await fetchListUseCase.execute(limit: limit, offset: offset)

                await MainActor.run {
                    self.totalCount = page.totalCount
                    self.nextOffset = page.nextOffset

                    if isRefresh {
                        self.items = page.items
                    } else {
                        // offset 0인데 items가 비어있으면 초기 로드로 간주
                        if offset == 0 && self.items.isEmpty {
                            self.items = page.items
                        } else {
                            self.items.append(contentsOf: page.items)
                        }
                    }

                    self.isLoading = false
                    self.isRefreshing = false
                    self.isRequesting = false
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.isRefreshing = false
                    self.isRequesting = false
                    self.onError?(self.mapError(error))
                }
            }
        }
    }

    // MARK: Error Mapping

    private func mapError(_ error: Error) -> String {
        if let useCaseError = error as? FetchPokemonListUseCaseError {
            switch useCaseError {
            case .invalidPaging:
                return "잘못된 페이지 요청입니다."
            }
        }

        if let networkError = error as? NetworkError {
            switch networkError {
            case .invalidURL:
                return "잘못된 URL입니다."
            case .invalidResponse:
                return "서버 응답이 올바르지 않습니다."
            case .httpStatus(let code, _):
                return "서버 오류가 발생했습니다. (HTTP \(code))"
            case .decoding:
                return "데이터 처리 중 오류가 발생했습니다."
            case .transport:
                return "네트워크 연결이 원활하지 않습니다."
            }
        }

        return "알 수 없는 오류가 발생했습니다."
    }
}
