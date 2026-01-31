//
//  PokemonNameTranslating.swift
//  PokeDex
//
//  Created by Hwangseokbeom on 1/31/26.
//

import Foundation

protocol PokemonNameTranslating {
    func koreanName(for englishName: String) -> String
}
