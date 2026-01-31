//
//  PokemonDetail.swift
//  PokeDex
//
//  Created by Hwangseokbeom on 1/31/26.
//

import Foundation

struct PokemonDetail: Equatable {
    let id: Int
    let koreanName: String
    let types: [PokemonTypeName]
    let heightDM: Int
    let weightHG: Int

    var heightMeters: Double { Double(heightDM) / 10.0 }
    var weightKg: Double { Double(weightHG) / 10.0 }
}
