//
//  VASideBarItem.swift
//  Vatterso
//
//  Created by Kristoffer Anger on 2023-07-26.
//

import Foundation

enum PageType {
    case blog([WPPost]), page(WPPost)
    
    var page: WPPost? {
        if case .page(let page) = self {
            return page
        }
        else {
            return nil
        }
    }
    
    var id: Int {
        switch self {
        case .blog(_):
            return 0
        case .page(let post):
            return post.id
        }
    }
    
    var title: String {
        switch self {
        case .blog(_):
            return "Hem"
        case .page(let post):
            return post.title.text
        }
    }
}


struct VASideBarItem: Identifiable {
    
    var pageType: PageType
    var items: [VASideBarItem]?
    
    init(page: WPPost, items: [VASideBarItem]? = nil) {
        self.pageType = .page(page)
        self.items = items
    }
    
    init(posts: [WPPost]) {
        self.pageType = .blog(posts)
    }
    
    var id: Int {
        return pageType.id
    }
    
    var name: String {
        return pageType.title
    }
    
    var page: WPPost? {
        return pageType.page
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

extension VASideBarItem: Equatable {
    
    static func == (lhs: VASideBarItem, rhs: VASideBarItem) -> Bool {
        lhs.id == rhs.id
    }
}
