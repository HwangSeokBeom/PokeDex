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

    private func makePokemonRepository() -> PokemonRepository {
        switch AppSettings.shared.dataSourceMode {
        case .local:
            let dataSource = LocalPokemonDataSource(bundle: .main, fileName: "pokemons")
            return LocalPokemonRepository(dataSource: dataSource)

        case .remote:
            let client = URLSessionHTTPClient()
            let translator = DefaultPokemonNameTranslator()
            return DefaultPokemonRepository(client: client, translator: translator)
        }
    }

    func makePokemonListViewController() -> UIViewController {
        let repository = makePokemonRepository()

        let fetchListUseCase: FetchPokemonListUseCasing = FetchPokemonListUseCase(repository: repository)
        let fetchDetailUseCase: FetchPokemonDetailUseCasing = FetchPokemonDetailUseCase(repository: repository)

        let vm = PokemonListViewModel(fetchListUseCase: fetchListUseCase)
        let vc = PokemonListViewController(viewModel: vm)

        return vc
    }

    func makePokemonDetailViewController(id: Int) -> UIViewController {
        let repository = makePokemonRepository()

        let useCase: FetchPokemonDetailUseCasing = FetchPokemonDetailUseCase(repository: repository)
        let vm = PokemonDetailViewModel(pokemonID: id, fetchDetailUseCase: useCase)
        let vc = PokemonDetailViewController(viewModel: vm)

        return vc
    }
}
