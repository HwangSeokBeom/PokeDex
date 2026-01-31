//
//  PokemonRepository.swift
//  PokeDex
//
//  Created by Hwangseokbeom on 1/31/26.
//

import Foundation

final class DefaultPokemonRepository: PokemonRepository {

    private let client: HTTPClient
    private let translator: PokemonNameTranslating

    init(
        client: HTTPClient,
        translator: PokemonNameTranslating
    ) {
        self.client = client
        self.translator = translator
    }

    func fetchPokemonList(limit: Int, offset: Int) async throws -> PokemonListPage {
        let dto = try await client.send(
            PokemonListDTO.self,
            endpoint: .pokemonList(limit: limit, offset: offset),
            method: .get
        )

        let items: [PokemonSummary] = dto.results.compactMap { item -> PokemonSummary? in
            guard let id = item.extractedID else { return nil }

            let korean = translator.koreanName(for: item.name)
            guard let imageURL = URL(string:
                "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(id).png"
            ) else { return nil }

            return PokemonSummary(
                id: id,
                englishName: item.name,
                koreanName: korean,
                imageURL: imageURL
            )
        }

        let nextOffset = offset + limit < dto.count ? offset + limit : nil

        return PokemonListPage(
            totalCount: dto.count,
            items: items,
            nextOffset: nextOffset
        )
    }

    func fetchPokemonDetail(id: Int) async throws -> PokemonDetail {
        let dto = try await client.send(
            PokemonDetailDTO.self,
            endpoint: .pokemonDetail(id: id),
            method: .get
        )

        let korean = translator.koreanName(for: dto.name)

        return dto.toDomain(koreanName: korean)
    }
}
