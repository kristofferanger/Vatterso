//
//  StartPageViewModel.swift
//  Vatterso
//
//  Created by Kristoffer Anger on 2023-07-13.
//

import Foundation
import Combine


class StartPageViewModel: ObservableObject {
    
    @Published var pages = LoadingData<[Page]>()
    
    private let pagesDataService: DataService<[Page]>
    private let postsDataService: DataService<[Post]>
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        self.pagesDataService = DataService<[Page]>()
        pagesDataService.url = NetworkingManager.url(endpoint: "/pages", parameters: ["context": "view", "orderby": "parent", "per_page": "100"])
        
        self.postsDataService = DataService<[Post]>()
        postsDataService.url = NetworkingManager.url(endpoint: "/posts", parameters: ["per_page": "100"])
        
        addSubscribers()
    }
    
    func loadPages() {
        pagesDataService.loadData()
    }

    private func addSubscribers() {
        
        pagesDataService.dataPublisher
            .sink { completion in
                print("Completion \(completion)")
            } receiveValue: { [weak self] pages in
                self?.pages = pages
            }
            .store(in: &cancellables)
        
    }
    
}
