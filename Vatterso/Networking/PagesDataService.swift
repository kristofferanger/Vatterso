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
    
    init(url: URL? = nil) {
        self.url = url
    }
    
    private var url: URL?
    private var pagesSubscription: AnyCancellable?

    func loadData() {
        guard let url else { return }
        pagesSubscription = NetworkingManager.download(url: url)
            .decode(type: [DataType].self, decoder: NetworkingManager.defaultDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: NetworkingManager.handleCompletion(completion:))
            { [weak self] receivedData in
                guard let self else { return }
                self.data = receivedData
                self.pagesSubscription?.cancel()
            }
    }
}
