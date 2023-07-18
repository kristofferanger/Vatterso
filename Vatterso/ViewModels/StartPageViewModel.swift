//
//  StartPageViewModel.swift
//  Vatterso
//
//  Created by Kristoffer Anger on 2023-07-13.
//

import Foundation
import Combine


class StartPageViewModel: ObservableObject {
    
    @Published var pages = ListData<[Page]>()
    
    private let pagesDataService: PagesDataServiceProtocol
    //private let postsDataService: PostsDataServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        self.pagesDataService = PagesDataService()
        addSubscribers()
    }
    
    func loadPages() {
        pagesDataService.loadPages()
    }

    private func addSubscribers() {
        pagesDataService.pagesPublisher
            .sink { completion in
                print("Completion \(completion)")
            } receiveValue: { [weak self] pages in
                self?.pages = pages
            }
            .store(in: &cancellables)
    }
    
}
