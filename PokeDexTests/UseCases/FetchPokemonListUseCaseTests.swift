//
//  Untitled.swift
//  PokeDex
//
//  Created by Hwangseokbeom on 2/19/26.
//

import XCTest
@testable import PokeDex

enum PokemonFactory {
    static func summary(
        id: Int = 1,
        englishName: String = "bulbasaur",
        koreanName: String = "이상해씨",
        imageURLString: String = "https://example.com/1.png"
    ) -> PokemonSummary {
        return PokemonSummary(
            id: id,
            englishName: englishName,
            koreanName: koreanName,
            imageURL: URL(string: imageURLString)!
        )
    }
}

extension PokemonFactory {
    static func detail(
        id: Int = 1,
        koreanName: String = "이상해씨",
        types: [PokemonTypeName] = [],
        heightDM: Int = 7,
        weightHG: Int = 69
    ) -> PokemonDetail {
        return PokemonDetail(
            id: id,
            koreanName: koreanName,
            types: types,
            heightDM: heightDM,
            weightHG: weightHG
        )
    }
}

final class FetchPokemonListUseCaseTests: XCTestCase {

    func test_execute_success_callsRepository_andReturnsPage() async throws {
        let spyRepo = SpyPokemonRepository()
        spyRepo.fetchListResult = .success(
            PokemonListPage(
                totalCount: 1,
                items: [PokemonFactory.summary(id: 1)],
                nextOffset: 20
            )
        )

        let useCase = FetchPokemonListUseCase(repository: spyRepo)

        let page = try await useCase.execute(limit: 20, offset: 0)

        XCTAssertTrue(spyRepo.fetchListCalled)
        XCTAssertEqual(spyRepo.fetchListCallCount, 1)
        XCTAssertEqual(spyRepo.fetchListCapturedLimit, 20)
        XCTAssertEqual(spyRepo.fetchListCapturedOffset, 0)

        XCTAssertEqual(page.totalCount, 1)
        XCTAssertEqual(page.items.count, 1)
        XCTAssertEqual(page.items.first?.id, 1)
        XCTAssertEqual(page.nextOffset, 20)
    }

    func test_execute_failure_propagatesError() async throws {
        let spyRepo = SpyPokemonRepository()
        spyRepo.fetchListResult = .failure(URLError(.notConnectedToInternet))

        let useCase = FetchPokemonListUseCase(repository: spyRepo)

        do {
            _ = try await useCase.execute(limit: 20, offset: 0)
            XCTFail("Expected error to be thrown")
        } catch {
        }
    }
}

final class FetchPokemonDetailUseCaseTests: XCTestCase {

    func test_execute_success_callsRepository_andReturnsDetail() async throws {
        let spyRepo = SpyPokemonRepository()
        let expected = PokemonFactory.detail(id: 1)

        spyRepo.fetchDetailResult = .success(expected)

        let useCase = FetchPokemonDetailUseCase(repository: spyRepo)

        let result = try await useCase.execute(id: 1)

        XCTAssertEqual(spyRepo.fetchDetailCallCount, 1)
        XCTAssertEqual(spyRepo.fetchDetailCapturedID, 1)

        XCTAssertEqual(result, expected)
    }

    func test_execute_invalidID_throws_andDoesNotCallRepository() async {
        let spyRepo = SpyPokemonRepository()
        let useCase = FetchPokemonDetailUseCase(repository: spyRepo)

        do {
            _ = try await useCase.execute(id: 0)
            XCTFail("Expected invalidID error to be thrown")
        } catch let error as FetchPokemonDetailUseCaseError {
            XCTAssertEqual(error, .invalidID)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }

        XCTAssertEqual(spyRepo.fetchDetailCallCount, 0)
        XCTAssertNil(spyRepo.fetchDetailCapturedID)
    }

    func test_execute_repositoryFailure_propagatesError() async {
        let spyRepo = SpyPokemonRepository()
        let expectedError = URLError(.notConnectedToInternet)

        spyRepo.fetchDetailResult = .failure(expectedError)

        let useCase = FetchPokemonDetailUseCase(repository: spyRepo)

        do {
            _ = try await useCase.execute(id: 1)
            XCTFail("Expected error to be thrown")
        } catch let error as URLError {
            XCTAssertEqual(error.code, expectedError.code)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }

        XCTAssertEqual(spyRepo.fetchDetailCallCount, 1)
        XCTAssertEqual(spyRepo.fetchDetailCapturedID, 1)
    }
}
