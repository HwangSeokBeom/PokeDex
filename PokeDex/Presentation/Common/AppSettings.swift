//
//  Untitled.swift
//  PokeDex
//
//  Created by Hwangseokbeom on 2/24/26.
//

import Foundation

enum DataSourceMode: String {
    case remote
    case local
}

final class AppSettings {
    static let shared = AppSettings()
    private init() {}

    private let modeKey = "DataSourceMode"

    var dataSourceMode: DataSourceMode {
        get {
            let raw = UserDefaults.standard.string(forKey: modeKey)
            return DataSourceMode(rawValue: raw ?? "") ?? .remote
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: modeKey)
        }
    }
}
