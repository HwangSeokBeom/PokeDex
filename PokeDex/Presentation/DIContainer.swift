//
//  DIContainer.swift
//  PokeDex
//
//  Created by Hwangseokbeom on 1/31/26.
//

import UIKit

final class DIContainer {
    static let shared = DIContainer()
    private init() {}

    func makePokemonListViewController() -> UIViewController {
        let client = URLSessionHTTPClient()
        let translator = DefaultPokemonNameTranslator()
        let repository: PokemonRepository = DefaultPokemonRepository(client: client, translator: translator)

        let fetchListUseCase: FetchPokemonListUseCasing = FetchPokemonListUseCase(repository: repository)
        let fetchDetailUseCase: FetchPokemonDetailUseCasing = FetchPokemonDetailUseCase(repository: repository)

        let vm = PokemonListViewModel(fetchListUseCase: fetchListUseCase)
        let vc = PokemonListViewController(viewModel: vm)

        return vc
    }

    func makePokemonDetailViewController(id: Int) -> UIViewController {
        let client = URLSessionHTTPClient()
        let translator = DefaultPokemonNameTranslator()
        let repository: PokemonRepository = DefaultPokemonRepository(client: client, translator: translator)

        let useCase: FetchPokemonDetailUseCasing = FetchPokemonDetailUseCase(repository: repository)
        let vm = PokemonDetailViewModel(pokemonID: id, fetchDetailUseCase: useCase)
        let vc = PokemonDetailViewController(viewModel: vm)
        return vc
    }
}
