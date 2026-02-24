//
//  LocalPokemonDTO.swift
//  PokeDex
//
//  Created by Hwangseokbeom on 2/24/26.
//

import Foundation

struct LocalPokemonResponseDTO: Decodable {
    let pokemons: [LocalPokemonDTO]
}

struct LocalPokemonDTO: Decodable {
    let id: Int
    let name: String
    let koreanName: String
    let heightDM: Int
    let weightHG: Int
    let types: [PokemonTypeName]
    let imageURLString: String

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case koreanName = "korean_name"
        case heightDM = "height_dm"
        case weightHG = "weight_hg"
        case types
        case imageURLString = "image_url"
    }
}
