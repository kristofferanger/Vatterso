//
//  PagesDataService.swift
//  Vatterso
//
//  Created by Kristoffer Anger on 2023-07-13.
//

import Foundation
import Combine


enum LoadingStatus {
    case unknown, loading, finished, error(NetworkingError)
}

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
                NetworkingManager.handleCompletion(completion: completion) { error in
                    self?.result = .failure(error)
                    self?.loadDataSubscription?.cancel()
                }
            }, receiveValue:{ [weak self] receivedData in
                self?.result = .success(receivedData)
                self?.loadDataSubscription?.cancel()
            })
    }
}


/*
 
 { [weak self] completion in
     if case .failure(let error) = completion {
         print("Some other error: \(error.localizedDescription)")
         self?.result = .failure(error as! NetworkingError)
     }
 }
 */
