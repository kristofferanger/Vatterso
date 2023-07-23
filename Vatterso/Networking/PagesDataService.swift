//
//  PagesDataService.swift
//  Vatterso
//
//  Created by Kristoffer Anger on 2023-07-13.
//

import Foundation
import Combine

protocol DataServiceProtocol {
    associatedtype T: Decodable
    // subscribe vars
    var dataPublisher: Published<LoadingData<T>>.Publisher { get }
    // method to ask for updates
    func loadData()
}

class DataService<T: Decodable>: DataServiceProtocol {
    
    var url: URL?
    @Published var data = LoadingData<T>()
    var dataPublisher: Published<LoadingData<T>>.Publisher { $data }
    
    private var pagesSubscription: AnyCancellable?

    func loadData() {
        guard let url else { return }
        pagesSubscription = NetworkingManager.download(url: url)
            .decode(type: T.self, decoder: NetworkingManager.defaultDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self else { return }
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    let networkingError = error as? NetworkingError ?? NetworkingError.unknown
                    self.data = .finished(.failure(networkingError))
                }
            }, receiveValue:{ [weak self] receivedData in
                guard let self else { return }
                self.data = .finished(.success(receivedData))
                self.pagesSubscription?.cancel()
            })
    }
}
