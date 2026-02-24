//
//  HTTPClient.swift
//  PokeDex
//
//  Created by Hwangseokbeom on 1/31/26.
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
}

protocol HTTPClient {
    func send<T: Decodable>(
        _ type: T.Type,
        endpoint: Endpoint,
        method: HTTPMethod
    ) async throws -> T
}

final class URLSessionHTTPClient: HTTPClient {

    private let session: URLSession
    private let decoder: JSONDecoder

    init(
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.session = session
        self.decoder = decoder
    }

    func send<T: Decodable>(
        _ type: T.Type,
        endpoint: Endpoint,
        method: HTTPMethod = .get
    ) async throws -> T {
        let data = try await send(endpoint: endpoint, method: method)
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decoding(error)
        }
    }

    func send(
        endpoint: Endpoint,
        method: HTTPMethod = .get
    ) async throws -> Data {
        let url = try endpoint.makeURL()

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        do {
            let (data, response) = try await session.data(for: request)

            guard let http = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }

            guard (200..<300).contains(http.statusCode) else {
                throw NetworkError.httpStatus(http.statusCode, data)
            }

            return data
        } catch let networkError as NetworkError {
            throw networkError
        } catch {
            throw NetworkError.transport(error)
        }
    }
}
