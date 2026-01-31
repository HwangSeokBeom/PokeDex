//
//  FetchPokemonListUseCase.swift
//  PokeDex
//
//  Created by Hwangseokbeom on 1/29/26.
//

import Foundation

protocol FetchPokemonListUseCasing {
    func execute(limit: Int, offset: Int) async throws -> PokemonListPage
}

final class FetchPokemonListUseCase: FetchPokemonListUseCasing {

    private let repository: PokemonRepository

    init(repository: PokemonRepository) {
        self.repository = repository
    }

    func execute(limit: Int, offset: Int) async throws -> PokemonListPage {
        // 도메인 규칙(입력 검증)을 UseCase에 둬도 좋음
        guard limit > 0, offset >= 0 else {
            throw FetchPokemonListUseCaseError.invalidPaging
        }

        return try await repository.fetchPokemonList(limit: limit, offset: offset)
    }
}

enum FetchPokemonListUseCaseError: Error, Equatable {
    case invalidPaging
}
