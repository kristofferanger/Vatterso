//
//  PagesDataService.swift
//  Vatterso
//
//  Created by Kristoffer Anger on 2023-07-13.
//

import Foundation
import Combine

protocol DataServiceProtocol {
    associatedtype DataType
    // subscribe vars
    var dataPublisher: Published<[DataType]>.Publisher { get }
    // method to ask for updates
    func loadData()
}

class DataService<DataType: Codable>: DataServiceProtocol {
    
    @Published var data = [DataType]()

    var dataPublisher: Published<[DataType]>.Publisher { $data }
    
    init(url: URL?) {
        guard let url else { return }
        self.request = URLRequest(url: url)
        self.request?.httpMethod = "GET"
    }
    
    init(request: URLRequest? = nil) {
        self.request = request
    }
    
    private var request: URLRequest?
    private var pagesSubscription: AnyCancellable?

    func loadData() {
        guard let request else { return }
        pagesSubscription = NetworkingManager.download(request: request)
            .decode(type: [DataType].self, decoder: NetworkingManager.defaultDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Some other error: \(error.localizedDescription)")
                    
                }
            }, receiveValue: { [weak self] receivedData in
                self?.data = receivedData
                self?.pagesSubscription?.cancel()
            })
    }
}
