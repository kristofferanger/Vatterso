//
//  StartPageViewModel.swift
//  Vatterso
//
//  Created by Kristoffer Anger on 2023-07-13.
//

import Foundation
import Combine


enum LoadingStatus {
    case unknown, loading, finnished, error(NetworkingError)
}

class StandardViewModel: ObservableObject {
    @Published var status: LoadingStatus = .unknown
}


class StartPageViewModel: StandardViewModel {
    
    @Published var pages = LoadingData<[Page]>()
    @Published var posts = LoadingData<[Page]>()

    private let pagesDataService = DataService<Page>(url: NetworkingManager.url(endpoint: "/pages", parameters: ["context": "view", "orderby": "parent", "per_page": "100"]))
    private let postsDataService = DataService<Page>(url: NetworkingManager.url(endpoint: "/posts", parameters: ["orderby": "date", "per_page": "100"]))
    private var cancellables = Set<AnyCancellable>()
    
    override init() {
        super.init()
        addSubscribers()
    }
    
    func loadPages() {
        postsDataService.loadData()
        pagesDataService.loadData()
        status = .loading
    }

    private func addSubscribers() {
        pagesDataService.dataPublisher
            .sink { completion in
                if case .failure(let error) = completion {
                    let networkingError = error as! NetworkingError
                    self.pages = .finished(.failure(networkingError))
                }
            } receiveValue: { [weak self] pages in
                self?.pages = .finished( .success(pages))
            }
            .store(in: &cancellables)
        
        postsDataService.dataPublisher
            .sink { completion in
                print("Completion \(completion)")
            } receiveValue: { [weak self] posts in
                self?.posts = .finished( .success(posts))
            }
            .store(in: &cancellables)
        
    }
    
}
