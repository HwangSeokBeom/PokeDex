//
//  LocalPokemonDataSource.swift
//  PokeDex
//
//  Created by Hwangseokbeom on 2/24/26.
//

import Foundation

enum LocalPokemonDataSourceError: Error, Equatable {
    case fileNotFound(String)
    case unreadableData(String)
    case decodingFailed
}

actor LocalPokemonDataSource {

    private let bundle: Bundle
    private let fileName: String
    private let decoder: JSONDecoder

    private var cached: [LocalPokemonDTO]?

    init(bundle: Bundle = .main, fileName: String = "pokemons", decoder: JSONDecoder = JSONDecoder()) {
        self.bundle = bundle
        self.fileName = fileName
        self.decoder = decoder
    }

    func loadAll() throws -> [LocalPokemonDTO] {
        if let cached { return cached }

        guard let url = bundle.url(forResource: fileName, withExtension: "json") else {
            throw LocalPokemonDataSourceError.fileNotFound("\(fileName).json")
        }

        let data: Data
        do {
            data = try Data(contentsOf: url)
        } catch {
            throw LocalPokemonDataSourceError.unreadableData(url.lastPathComponent)
        }

        let decoded: LocalPokemonResponseDTO
        do {
            decoded = try decoder.decode(LocalPokemonResponseDTO.self, from: data)
        } catch {
            throw LocalPokemonDataSourceError.decodingFailed
        }

        // 페이징 안정성을 위해 id 정렬
        let sorted = decoded.pokemons.sorted { $0.id < $1.id }
        self.cached = sorted
        return sorted
    }
}
