//
//  PokemonDetailDTO.swift
//  PokeDex
//
//  Created by Hwangseokbeom on 1/31/26.
//

import Foundation

struct PokemonDetailDTO: Decodable {
    let id: Int
    let name: String
    let height: Int
    let weight: Int
    let types: [TypeEntryDTO]
}

extension PokemonDetailDTO {
    
    struct TypeEntryDTO: Decodable {
        let slot: Int
        let type: TypeDTO
    }
    
    struct TypeDTO: Decodable {
        let name: String
        let url: String
    }
}

extension PokemonDetailDTO {

    func toDomain(
        koreanName: String
    ) -> PokemonDetail {

        let mappedTypes: [PokemonTypeName] = types.compactMap {
            PokemonTypeName(rawValue: $0.type.name)
        }

        return PokemonDetail(
            id: id,
            koreanName: koreanName,
            types: mappedTypes,
            heightDM: height,
            weightHG: weight
        )
    }
}
