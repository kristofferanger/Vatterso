//
//  NetworkManager.swift
//  iOSTechTask
//
//  Created by Kristoffer Anger on 2023-07-03.
//

import Foundation
import Combine


class NetworkingManager {
    
    static func download(url: URL) -> AnyPublisher<Data, Error> {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        return download(request: request)
    }
    
    static func download(request: URLRequest) -> AnyPublisher<Data, Error> {
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { try handleURLResponse(output: $0, url: request.url) }
            .retry(3)
            .eraseToAnyPublisher()
    }
    
    static func handleURLResponse(output: URLSession.DataTaskPublisher.Output, url: URL?) throws -> Data {
        guard let response = output.response as? HTTPURLResponse else {
            throw NetworkingError.unknown
        }
        guard (200..<300).contains(response.statusCode) else {
            let urlString = response.url?.absoluteString ?? url?.absoluteString ?? "URL is missing!"
            throw NetworkingError.badURLResponse(urlString: urlString, statusCode: response.statusCode)
        }
        return output.data
    }
}

// API constants
extension NetworkingManager {
    enum API {
        case production, mock
    }
    
    private static let api: API = .production
    private static let baseUrl = "https://wetterso.se/wp-json/wp/v2"
    
    static func url(endpoint: String, parameters: [String: String?] = [:]) -> URL? {
        var urlString: String
        switch api {
        case .production:
            urlString = baseUrl + endpoint
        case .mock:
            fatalError("[🛑] Mock data service should not use the network!")
        }
        return URL(string: urlString)?.appending(queryItems: parameters.map { URLQueryItem(name: $0, value: $1) })
    }
    
    static func defaultDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}

// MARK: Helpers

enum NetworkingError: LocalizedError, Identifiable {
    case badURLResponse(urlString: String, statusCode: Int)
    case unknown
    case noNetwork
    
    var errorDescription: String? {
        switch self {
        case .badURLResponse(let url, let statusCode):
            return "[🔥] Status code: \(statusCode). Bad response from URL: \(url)"
        case .unknown:
            return "[⚡️] Unknown error occured"
        case .noNetwork:
            return "[⚠️] No network found"
        }
    }
    
    init(error: Error) {
        if let error = error as? NetworkingError {
            self = error
        }
        else if let urlError = error as? URLError, urlError.code == URLError.Code.notConnectedToInternet {
            self = NetworkingError.noNetwork
        }
        else {
            self = NetworkingError.unknown
        }
    }

    var id: String {
        return UUID().uuidString
    }
}
