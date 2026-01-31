//
//  PokemonDetailViewModel.swift
//  PokeDex
//
//  Created by Hwangseokbeom on 1/31/26.
//

import Foundation

protocol PokemonDetailViewModelInput: AnyObject {
    func load()
}

protocol PokemonDetailViewModelOutput: AnyObject {
    var detail: PokemonDetail? { get }

    var onUpdate: (() -> Void)? { get set }
    var onError: ((String) -> Void)? { get set }
    var onLoadingChange: ((Bool) -> Void)? { get set }
}

final class PokemonDetailViewModel: PokemonDetailViewModelInput, PokemonDetailViewModelOutput {

    // Output
    private(set) var detail: PokemonDetail? {
        didSet { onUpdate?() }
    }

    var onUpdate: (() -> Void)?
    var onError: ((String) -> Void)?
    var onLoadingChange: ((Bool) -> Void)?

    // Dependencies
    private let pokemonID: Int
    private let fetchDetailUseCase: FetchPokemonDetailUseCasing

    init(
        pokemonID: Int,
        fetchDetailUseCase: FetchPokemonDetailUseCasing
    ) {
        self.pokemonID = pokemonID
        self.fetchDetailUseCase = fetchDetailUseCase
    }

    func load() {
        onLoadingChange?(true)

        Task { [weak self] in
            guard let self else { return }
            do {
                let result = try await fetchDetailUseCase.execute(id: pokemonID)
                await MainActor.run {
                    self.onLoadingChange?(false)
                    self.detail = result
                }
            } catch {
                await MainActor.run {
                    self.onLoadingChange?(false)
                    self.onError?(self.mapError(error))
                }
            }
        }
    }

    // MARK: - Error Mapping

    private func mapError(_ error: Error) -> String {
        if let useCaseError = error as? FetchPokemonDetailUseCaseError {
            switch useCaseError {
            case .invalidID:
                return "유효하지 않은 포켓몬 번호입니다."
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
