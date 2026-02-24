//
//  Untitled.swift
//  PokeDex
//
//  Created by Hwangseokbeom on 1/31/26.
//

import Foundation

final class DefaultPokemonNameTranslator: PokemonNameTranslating {
    func koreanName(for englishName: String) -> String {
        PokemonTranslator.getKoreanName(for: englishName)
    }
}
