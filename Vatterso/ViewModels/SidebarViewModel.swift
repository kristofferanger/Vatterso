//
//  SidebarViewModel.swift
//  Vatterso
//
//  Created by Kristoffer Anger on 2023-07-31.
//

import Foundation
import Combine

enum LoadingStatus {
    case unknown, loading, finished, error(NetworkingError)
}

class SidebarViewModel: ObservableObject {
    
    @Published var items: [VASideBarItem] = []
    @Published var loadingStatus: LoadingStatus = .unknown

    private let pagesDataService = DataService<WPPost>(url: NetworkingManager.url(endpoint: "/pages", parameters: ["context": "view", "per_page": "100"]))
    private let postsDataService = DataService<WPPost>(url: NetworkingManager.url(endpoint: "/posts", parameters: ["orderby": "date", "per_page": "100"]))
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        addSubscribers()
    }
    
    func loadPages() {
        pagesDataService.loadData()
        postsDataService.loadData()
        loadingStatus = .loading
    }

    private func addSubscribers() {
        pagesDataService.dataPublisher
            .combineLatest(postsDataService.dataPublisher)
            .map{ pages, posts in
                let blog = [VASideBarItem(posts: posts)]
                let pages = VASideBarItem.sorted(pages: pages)
                return blog + pages
            }
            .print("debugging")
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    self?.loadingStatus = .error(error)
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] items in
                self?.loadingStatus = .finished
                self?.items = items
            })
            .store(in: &cancellables)
    }
}
