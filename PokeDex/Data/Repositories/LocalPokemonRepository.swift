//
//  LocalPokemonRepository.swift
//  PokeDex
//
//  Created by Hwangseokbeom on 2/24/26.
//

import Foundation

enum LocalPokemonRepositoryError: Error, Equatable {
    case invalidImageURL(String)
    case notFound(id: Int)
    case invalidPaging(limit: Int, offset: Int)
}

final class LocalPokemonRepository: PokemonRepository {

    private let dataSource: LocalPokemonDataSource

    init(dataSource: LocalPokemonDataSource) {
        self.dataSource = dataSource
    }

    func fetchPokemonList(limit: Int, offset: Int) async throws -> PokemonListPage {
        guard limit > 0, offset >= 0 else {
            throw LocalPokemonRepositoryError.invalidPaging(limit: limit, offset: offset)
        }

        let all = try await dataSource.loadAll()

        if offset >= all.count {
            return PokemonListPage(totalCount: all.count, items: [], nextOffset: nil)
        }

        let slice = Array(all.dropFirst(offset).prefix(limit))

        let items: [PokemonSummary] = try slice.map { dto in
            guard let url = URL(string: dto.imageURLString) else {
                throw LocalPokemonRepositoryError.invalidImageURL(dto.imageURLString)
            }
            return PokemonSummary(
                id: dto.id,
                englishName: dto.name,
                koreanName: dto.koreanName,
                imageURL: url
            )
        }

        let next = (offset + limit) < all.count ? (offset + limit) : nil

        return PokemonListPage(
            totalCount: all.count,
            items: items,
            nextOffset: next
        )
    }

    func fetchPokemonDetail(id: Int) async throws -> PokemonDetail {
        let all = try await dataSource.loadAll()

        guard let dto = all.first(where: { $0.id == id }) else {
            throw LocalPokemonRepositoryError.notFound(id: id)
        }

        return PokemonDetail(
            id: dto.id,
            koreanName: dto.koreanName,
            types: dto.types,
            heightDM: dto.heightDM,
            weightHG: dto.weightHG
        )
    }
}
