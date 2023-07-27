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

struct Bookmark: Identifiable {
    var page: Page
    var items: [Bookmark]?
    
    var id: Int {
        return page.id
    }
    
    var name: String {
        return page.title.text
    }
    
    var icon: String? {
        switch self.name.lowercased() {
        case "wfff", "vnsf", "vsbsf":
            return "person.3"
        case "hem":
            return "house"
        case "resa till vättersö":
            return "ferry"
        case "brandvärn":
            return "flame"
        case "praktisk information":
            return "info.circle"
        case "tomtkarta":
            return "map"
        default:
            return nil
        
        }
    }
}


class StartPageViewModel: StandardViewModel {
    
    @Published var pageList = [Bookmark]()

    private let pagesDataService = DataService<Page>(url: NetworkingManager.url(endpoint: "/pages", parameters: ["context": "view", "per_page": "1000"]))
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
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    let networkingError = error as! NetworkingError
                    self?.status = .error(networkingError)
                }
            } receiveValue: { [weak self] pages in
                self?.status = .finnished
                self?.pageList = pages.compactMap{ page in
                    guard let parent = page.parent, parent == 0 else { return nil }
                    let children = pages.filter{ page.id == $0.parent }.map{ Bookmark(page: $0) }
                    return Bookmark(page: page, items: children.isEmpty ? nil : children)
                }
            }
            .store(in: &cancellables)
        
//        postsDataService.dataPublisher
//            .sink { completion in
//                print("Completion \(completion)")
//            } receiveValue: { [weak self] posts in
//                self?.posts = .finished( .success(posts))
//            }
//            .store(in: &cancellables)
        
    }
}
