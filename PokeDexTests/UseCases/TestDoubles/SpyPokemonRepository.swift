//
//  Untitled.swift
//  PokeDex
//
//  Created by Hwangseokbeom on 2/19/26.
//

import Foundation

final class SpyPokemonRepository: PokemonRepository {

    private(set) var fetchListCalled = false
    private(set) var fetchListCallCount = 0
    private(set) var fetchListCapturedLimit: Int?
    private(set) var fetchListCapturedOffset: Int?

    var fetchListResult: Result<PokemonListPage, Error> = .success(
        PokemonListPage(totalCount: 0, items: [], nextOffset: nil)
    )

    func fetchPokemonList(limit: Int, offset: Int) async throws -> PokemonListPage {
        fetchListCalled = true
        fetchListCallCount += 1
        fetchListCapturedLimit = limit
        fetchListCapturedOffset = offset

        return try fetchListResult.get()
    }

    private(set) var fetchDetailCallCount = 0
    private(set) var fetchDetailCapturedID: Int?

    var fetchDetailResult: Result<PokemonDetail, Error> = .failure(NSError(domain: "SpyPokemonRepository", code: -1))

    func fetchPokemonDetail(id: Int) async throws -> PokemonDetail {
        fetchDetailCallCount += 1
        fetchDetailCapturedID = id
        return try fetchDetailResult.get()
    }
}
