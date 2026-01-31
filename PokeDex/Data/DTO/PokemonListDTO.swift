//
//  PokemonListDTO.swift
//  PokeDex
//
//  Created by Hwangseokbeom on 1/31/26.
//

import Foundation

struct PokemonListDTO: Decodable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [PokemonListItemDTO]
}

struct PokemonListItemDTO: Decodable {
    let name: String
    let url: String
}
