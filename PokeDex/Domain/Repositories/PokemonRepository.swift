//
//  PokemonRepository.swift
//  PokeDex
//
//  Created by Hwangseokbeom on 1/31/26.
//

import Foundation

// MARK: - Repository (Domain Abstraction)

/// Domain Layer: UseCase가 의존하는 추상화.
/// Data Layer에서 DefaultPokemonRepository가 구현한다.
protocol PokemonRepository {
    
    /// 포켓몬 목록 (offset pagination)
    func fetchPokemonList(limit: Int, offset: Int) async throws -> PokemonListPage
    
    /// 포켓몬 상세 (요구사항: 번호, 한글 이름, 타입, 키, 몸무게)
    func fetchPokemonDetail(id: Int) async throws -> PokemonDetail
}

// MARK: - List Models (Domain)

/// 목록 그리드 셀에 필요한 최소 정보
struct PokemonSummary: Equatable {
    let id: Int
    let englishName: String
    let koreanName: String
    let imageURL: URL
    
    init(id: Int, englishName: String, koreanName: String, imageURL: URL) {
        self.id = id
        self.englishName = englishName
        self.koreanName = koreanName
        self.imageURL = imageURL
    }
}

/// 페이징 결과
struct PokemonListPage: Equatable {
    let totalCount: Int
    let items: [PokemonSummary]
    let nextOffset: Int?   // 다음 페이지 없으면 nil
    
    init(totalCount: Int, items: [PokemonSummary], nextOffset: Int?) {
        self.totalCount = totalCount
        self.items = items
        self.nextOffset = nextOffset
    }
}
