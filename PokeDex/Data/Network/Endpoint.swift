//
//  Endpoint.swift
//  PokeDex
//
//  Created by Hwangseokbeom on 1/31/26.
//

import Foundation

struct Endpoint {
    let baseURL: URL
    let path: String
    let queryItems: [URLQueryItem]

    init(
        baseURL: URL = URL(string: "https://pokeapi.co/api/v2")!,
        path: String,
        queryItems: [URLQueryItem] = []
    ) {
        self.baseURL = baseURL
        self.path = path
        self.queryItems = queryItems
    }

    func makeURL() throws -> URL {
        guard var components = URLComponents(
            url: baseURL.appendingPathComponent(path),
            resolvingAgainstBaseURL: false
        ) else {
            throw NetworkError.invalidURL
        }

        if !queryItems.isEmpty { components.queryItems = queryItems }
        guard let url = components.url else { throw NetworkError.invalidURL }
        return url
    }
}

extension Endpoint {
    static func pokemonList(limit: Int, offset: Int) -> Endpoint {
        Endpoint(
            path: "pokemon",
            queryItems: [
                URLQueryItem(name: "limit", value: "\(limit)"),
                URLQueryItem(name: "offset", value: "\(offset)")
            ]
        )
    }

    static func pokemonDetail(id: Int) -> Endpoint {
        Endpoint(path: "pokemon/\(id)")
    }

    static func pokemonSpecies(id: Int) -> Endpoint {
        Endpoint(path: "pokemon-species/\(id)")
    }
}
