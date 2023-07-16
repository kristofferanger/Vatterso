//
//  StartPageViewModel.swift
//  Vatterso
//
//  Created by Kristoffer Anger on 2023-07-13.
//

import Foundation
import Combine

enum LoadingStatus {
    case loading
    case error
    case finished([Page])
}

class StartPageViewModel: ObservableObject {
    
    @Published var pageLoading = LoadingStatus.finished([])

    
    private let dataService: PagesDataServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        self.dataService = PagesDataService()
        addSubscribers()
    }
    
    func loadPages() {
        pageLoading = .loading
        dataService.loadPages()
    }

    private func addSubscribers() {
        dataService.pagesPublisher
            .sink { _ in
                print("hep")
            } receiveValue: { [weak self] pages in
                self?.pageLoading = .finished(pages)
            }
            .store(in: &cancellables)
    }
    
}
