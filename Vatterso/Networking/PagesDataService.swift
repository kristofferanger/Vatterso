//
//  PagesDataService.swift
//  Vatterso
//
//  Created by Kristoffer Anger on 2023-07-13.
//

import Foundation
import Combine

protocol PagesDataServiceProtocol {
    // subscribe vars
    var pagesPublisher: Published<ListData<[Page]>>.Publisher { get }
    // method to ask for updates
    func loadPages()
}

class PagesDataService: PagesDataServiceProtocol {
    
    var pagesPublisher: Published<ListData<[Page]>>.Publisher { $allPages }
    
    @Published var allPages = ListData<[Page]>()
    
    private var pagesSubscription: AnyCancellable?

    func loadPages() {
        guard let url = NetworkingManager.url(endpoint: "/pages?context=view&orderby=parent&per_page=100") else {
            return
        }
        pagesSubscription = NetworkingManager.download(url: url)
            .decode(type: [Page].self, decoder: NetworkingManager.defaultDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: NetworkingManager.handleCompletion, receiveValue: { [weak self] receivedData in
                guard let self else { return }
                self.allPages = .finished(.success(receivedData))
                self.pagesSubscription?.cancel()
            })
    }
}
