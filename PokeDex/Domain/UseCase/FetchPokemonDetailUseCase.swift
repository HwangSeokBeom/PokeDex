//
//  FetchPokemonDetailUseCase.swift
//  PokeDex
//
//  Created by Hwangseokbeom on 1/29/26.
//

import Foundation

protocol FetchPokemonDetailUseCasing {
    func execute(id: Int) async throws -> PokemonDetail
}

final class FetchPokemonDetailUseCase: FetchPokemonDetailUseCasing {

    private let repository: PokemonRepository

    init(repository: PokemonRepository) {
        self.repository = repository
    }

    func execute(id: Int) async throws -> PokemonDetail {
        guard id > 0 else {
            throw FetchPokemonDetailUseCaseError.invalidID
        }
        return try await repository.fetchPokemonDetail(id: id)
    }
}

enum FetchPokemonDetailUseCaseError: Error, Equatable {
    case invalidID
}
