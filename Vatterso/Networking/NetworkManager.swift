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
            .retry(3)
            .tryMap { output in
                // handle output, store data or throw error
                let newData = try handleURLResponse(output: output, url: request.url)
                self.storeData(newData, url: request.url)
                return newData
            }
            .tryCatch { error in
                // fetch stored data or throw error
                guard let storedData = fetchStoredData(url: request.url) else { throw error }
                return Just(storedData)
            }
            .eraseToAnyPublisher()
    }
    
    static func storeData(_ data: Data, url: URL?) {
        
        guard let manager = DBManager(),
              let urlString = url?.absoluteString,
              let jsonString = String(data: data, encoding: .utf8)
        else { return }
        let recentDownload = RecentDownload(id: urlString, date: Date(), data: jsonString)
        manager.insert(item: recentDownload)
    }
    
    static func fetchStoredData(url: URL?) -> Data? {
        guard let urlString = url?.absoluteString,
              let manager = DBManager(),
              let item = manager.fetchItem(id: urlString, type: RecentDownload.self)
        else { return nil }
        
        if (Date().timeIntervalSince1970 - item.date.timeIntervalSince1970) < 3000 {
            print("It's fresh")
        }
        
        //let request = try manager.fetchItem(id: urlString)
//        return request
        // return DBManager.DBItem(id: "", date: Date(), data: Data()).data
        
        let data: Data? = item.data.data(using: .utf8)
        
        return data
    }
    
    static func handleURLResponse(output: URLSession.DataTaskPublisher.Output, url: URL?) throws -> Data {
        guard let response = output.response as? HTTPURLResponse else {
            throw NetworkingError.unknown
        }
        guard let url = url?.absoluteString else {
            throw NetworkingError.malformedURL(urlString: String(describing: url))
        }
        guard (200..<300).contains(response.statusCode) else {
            // prefer the response url (since it contains also any body parameters)
            let urlString = response.url?.absoluteString ?? url
            throw NetworkingError.badURLResponse(urlString: urlString, statusCode: response.statusCode)
        }
        // return the data if no errors were detected
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
    //"https://connecthotels.se/wp-json/wp/v2"
    //"https://techcrunch.com/wp-json/wp/v2"
    //"https://www.katyperry.com/wp-json/wp/v2"
    
    static func url(endpoint: String, parameters: [String: String?] = [:]) -> URL? {
        var urlString: String
        switch api {
        case .production:
            urlString = baseUrl + endpoint
        case .mock:
            fatalError("[🛑] Mock data service should not use the network!")
        }
        
        let queryItems = parameters.map { URLQueryItem(name: $0, value: $1) }
        var components = URLComponents(string: urlString)
        components?.queryItems = queryItems
        return components?.url
    }
    
    static func defaultDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .custom{ decoder in
            // date format: 2023-06-28T18:38:37
            let container = try decoder.singleValueContainer()
            let dateStr = try container.decode(String.self)
            // try iso8601 formats generally
            let iso8601Formatter = ISO8601DateFormatter()
            if let date = iso8601Formatter.date(from: dateStr) {
                return date
            }
            // try specific format of type 2023-06-28T18:38:37
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            if let date = formatter.date(from: dateStr) {
                return date
            }
            // return whatever
            return Date.distantPast
        }
        return decoder
    }
    
    static func defaultEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }
}

// MARK: Helpers

struct RecentDownload: DBItem {
    
    let id: String
    let date: Date
    let data: String
    
    var unixDate: TimeInterval {
        self.date.timeIntervalSince1970
    }
    
    // DBItem protocol
    func valueFor(columnLabel: String) -> Any? {
        switch columnLabel {
        case "id":
            return self.id
        case "date":
            return self.unixDate
        case "data":
            return self.data
        default:
            return nil
        }
    }
    
    static var colums: [(label: String, type: DBType)] {
        return [("id", .string), ("date", .float), ("data", .string)]
    }
    static var tableName: String {
        return "downloads"
    }
}

enum NetworkingError: LocalizedError, Identifiable {
    case malformedURL(urlString: String)
    case noNetwork
    case badURLResponse(urlString: String, statusCode: Int)
    case decodingError(reason: String)
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .badURLResponse(let url, let statusCode):
            return "[🔥] Status code: \(statusCode). Bad response from URL: \(url)"
        case .decodingError(let reason):
            return "[💣] Data could not be parsed. \(reason)"
        case .unknown:
            return "[⚡️] Unknown error occured"
        case .noNetwork:
            return "[⚠️] No network found"
        case .malformedURL(urlString: let url):
            return "[?¿] Cannot make sense of URL: \(url)"
        }
    }
    
    init(error: Error) {
        if let error = error as? NetworkingError {
            self = error
        }
        else if let urlError = error as? URLError, urlError.code == URLError.Code.notConnectedToInternet {
            self = NetworkingError.noNetwork
        }
        else if let decodingError = error as? DecodingError {
            var errorMessage: String = ""
            switch decodingError {
            case .dataCorrupted(let corrupted):
                errorMessage = "Data is corrupted: \(corrupted)"
            case .keyNotFound(let key, _):
                errorMessage = "Key not found: \(key)"
            case .typeMismatch(let type, _):
                errorMessage = "Type mismatch: \(type)"
            case .valueNotFound(let value, _):
                errorMessage = "Value not found: \(value)"
            default:
                errorMessage = "Unknown decoding error"
            }
            print(errorMessage)
            self = NetworkingError.decodingError(reason: "")
        }
        else {
            self = NetworkingError.unknown
        }
    }

    var id: String {
        return UUID().uuidString
    }
}
