//
//  NetworkError.swift
//  PokeDex
//
//  Created by Hwangseokbeom on 1/31/26.
//

import Foundation

enum NetworkError: Error, Equatable {
    case invalidURL
    case invalidResponse
    case httpStatus(Int, Data?)
    case decoding(Error)
    case transport(Error)

    static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL),
             (.invalidResponse, .invalidResponse):
            return true

        case let (.httpStatus(aCode, aData), .httpStatus(bCode, bData)):
            // 보통 테스트에서는 statusCode만 비교하면 충분
            // data까지 비교하고 싶으면 아래 줄을 `aData == bData`로 켜도 됨
            return aCode == bCode && aData == bData

        case let (.decoding(aErr), .decoding(bErr)):
            // 디코딩 에러는 구체 타입/메시지까지 비교하면 테스트가 깨지기 쉬워서
            // "같은 케이스인지"만 비교하는 식으로 많이 갑니다.
            return String(describing: type(of: aErr)) == String(describing: type(of: bErr))

        case let (.transport(aErr), .transport(bErr)):
            return (aErr as NSError).domain == (bErr as NSError).domain
                && (aErr as NSError).code == (bErr as NSError).code

        default:
            return false
        }
    }
}
