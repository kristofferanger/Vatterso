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
    var dataPublisher: PassthroughSubject<[DataType], NetworkingError> { get }
    // method to ask for updates
    func loadData()
}

class DataService<DataType: Codable>: DataServiceProtocol {
    
    var dataPublisher = PassthroughSubject<[DataType], NetworkingError>()
    
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
                switch completion {
                case .failure(let error):
                    // set failed result
                    self?.dataPublisher.send(completion: .failure(NetworkingError(error: error)))
                case .finished:
                    self?.dataPublisher.send(completion: .finished)
                }
                // cancel subscription
                self?.loadDataSubscription?.cancel()
            }, receiveValue:{ [weak self] receivedData in
                // set succeeded result
                self?.dataPublisher.send(receivedData)
            })
    }
}
