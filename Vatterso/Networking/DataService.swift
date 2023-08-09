//
//  DataService.swift
//  Vatterso
//
//  Created by Kristoffer Anger on 2023-07-25.
//

import Foundation
import Combine

protocol DataServiceProtocol {
    associatedtype DataType
    
    // subscribe vars
    var dataPublisher: Published<Result<[DataType], NetworkingError>>.Publisher { get }
    
    // method to ask for updates
    func loadData()
}

class DataService<DataType: Codable>: DataServiceProtocol {
        
    @Published var result: Result<[DataType], NetworkingError> = .success([])
    
    var dataPublisher: Published<Result<[DataType], NetworkingError>>.Publisher { $result }
    
    init(url: URL?) {
        guard let url else { fatalError("[💣] Malformed URL!") }
        self.request = URLRequest(url: url)
        self.request.httpMethod = "GET"
    }
    
    init(request: URLRequest) {
        self.request = request
    }
    
    private var request: URLRequest
    private var loadDataSubscription: AnyCancellable?

    func loadData() {
        loadDataSubscription = NetworkingManager.download(request: request)
            .decode(type: [DataType].self, decoder: NetworkingManager.defaultDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    // set failed result
                    self?.result = .failure(NetworkingError(error: error))
                }
                // cancel subscription
                self?.loadDataSubscription?.cancel()
            }, receiveValue:{ [weak self] receivedData in
                // set succeeded result
                self?.result = .success(receivedData)
            })
    }
}
