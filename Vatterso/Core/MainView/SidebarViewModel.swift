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
    
    @Published var items: [SidebarItem] = []
    @Published var loadingStatus: LoadingStatus = .unknown
    
    private var updatePageDataService: DataService<WPPost>?
    private let pagesDataService = DataService<[WPPost]>(url: NetworkingManager.url(endpoint: "/pages", parameters: [("context", "view"), ("orderby", "menu_order"), ("order", "asc"), ("per_page", "100")]))
    private let postsDataService = DataService<[WPPost]>(url: NetworkingManager.url(endpoint: "/posts", parameters: [("orderby", "date"), ("_embed", nil), ("per_page", "100")]))
    private var cancellables = Set<AnyCancellable>()

    func loadPages() {
        addSubscribers()
        pagesDataService.loadData()
        postsDataService.loadData()
        loadingStatus = .loading
    }
    
    func loadPosts() {
        addPostDataSubscriber()
        postsDataService.loadData()
        loadingStatus = .loading
    }
    
    func reloadPage(id: Int) {
        updatePageDataService = DataService<WPPost>(url: NetworkingManager.url(endpoint: "/pages/\(id)"))
        addUpdatePageDataSubscriber()
        updatePageDataService?.loadData()
    }
    
    func addUpdatePageDataSubscriber() {
        updatePageDataService?.dataPublisher
            .eraseToAnyPublisher()
            .compactMap { page in
                return SidebarItem(page: page)
            }
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    self?.loadingStatus = .error(error)
                case .finished:
                    self?.loadingStatus = .finished
                }
            }, receiveValue: { [weak self] page in
                if let index = self?.items.firstIndex(where: { $0.id == page.id }) {
                    self?.items[index] = page
                }
            })
            .store(in: &cancellables)
    }
    
    func addPostDataSubscriber() {
        postsDataService.dataPublisher
            .eraseToAnyPublisher()
            .compactMap { posts in
                return SidebarItem(posts: posts)
            }
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    self?.loadingStatus = .error(error)
                case .finished:
                    self?.loadingStatus = .finished
                }
            }, receiveValue: { [weak self] blog in
                self?.items[0] = blog
            })
            .store(in: &cancellables)
    }

    private func addSubscribers() {
        pagesDataService.dataPublisher
            .combineLatest(postsDataService.dataPublisher)
            .eraseToAnyPublisher()
            .compactMap{ pages, posts in
                let blog = [SidebarItem(posts: posts)]
                let pages = SidebarItem.sorted(pages: pages)
                return blog + pages
            }
            //.print("debugging")
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    self?.loadingStatus = .error(error)
                case .finished:
                    self?.loadingStatus = .finished
                }
            }, receiveValue: { [weak self] items in
                self?.items = items
            })
            .store(in: &cancellables)
    }
}
