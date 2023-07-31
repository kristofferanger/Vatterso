//
//  StartPageViewModel.swift
//  Vatterso
//
//  Created by Kristoffer Anger on 2023-07-13.
//

import Foundation
import Combine

class StartPageViewModel: ObservableObject {
    
    @Published var sideBarItems = [VASideBarItem]()
    @Published var loadingStatus: LoadingStatus = .unknown
    @Published var posts = [WPPost]()

    private let pagesDataService = DataService<WPPost>(url: NetworkingManager.url(endpoint: "/pages", parameters: ["context": "view", "per_page": "100"]))
    private let postsDataService = DataService<WPPost>(url: NetworkingManager.url(endpoint: "/posts", parameters: ["orderby": "date", "per_page": "100"]))
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        addSubscribers()
    }
    
    func loadPages() {
        postsDataService.loadData()
        pagesDataService.loadData()
        loadingStatus = .loading
    }

    private func addSubscribers() {
        pagesDataService.dataPublisher
            .sink { [weak self] result in
                switch result {
                case .success(let pages):
                    self?.loadingStatus = .finished
                    self?.sideBarItems = pages.compactMap{ page in
                        guard let parent = page.parent, parent == 0 else { return nil }
                        let children = pages.filter{ page.id == $0.parent }.map{ VASideBarItem(page: $0) }
                        return VASideBarItem(page: page, items: children.isEmpty ? nil : children)
                    }
                case .failure(let error):
                    self?.loadingStatus = .error(error)
                }
            }
            .store(in: &cancellables)
    }
}
