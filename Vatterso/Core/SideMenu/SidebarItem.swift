//
//  SidebarItem.swift
//  Vatterso
//
//  Created by Kristoffer Anger on 2023-08-14.
//

import Foundation

@objc enum PageType: Int {
    case blog, page
}

struct SidebarItem: Identifiable {
    // MARK: - Core Data Managed Object
    var pageType: PageType
    var posts: [WPPost]
    var items: [SidebarItem]?
    
    // calculated properties
    var page: WPPost? {
        guard self.pageType == .page else { return nil }
        return posts.first
    }
    
    var id: Int {
        if let page = self.page {
            return page.id
        }
        else {
            return PageType.blog.rawValue
        }
    }
     
    var tabId: Int {
        switch pageType {
        case .blog:
            return PageType.blog.rawValue
        case .page:
            guard let page = self.page, let parent = page.parent else { return PageType.page.rawValue }
            // pages with parent == 0 is on top, so then use it's own id
            let tabId = parent == 0 ? page.id : parent
            return tabId
        }
    }
    
    var title: String {
        if let page = self.page {
            return page.title.text
        }
        else {
            return "Hem"
        }
    }
    
    init(posts: [WPPost]) {
        self.pageType = .blog
        self.posts = posts
    }
    
    init(page: WPPost, items: [SidebarItem]? = nil) {
        self.pageType = .page
        self.posts = [page]
        self.items = items
    }
    
    static func sorted(pages: [WPPost]) -> [SidebarItem] {
        return pages.compactMap { page in
            // only add pages that are on top level, ie parents
            guard let parent = page.parent, parent == 0 else { return nil }
            // find children to parents
            let children = pages.filter{ page.id == $0.parent }.map{ SidebarItem(page: $0) }
            // create side bar items including parent and it's children
            return  SidebarItem(page: page, items: children.isEmpty ? nil : children)
        }
    }
    
    var icon: String? {
        // icons for pages
        switch self.title.lowercased() {
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

extension SidebarItem: Equatable {
    static func == (lhs: SidebarItem, rhs: SidebarItem) -> Bool {
        lhs.id == rhs.id
    }
}

extension SidebarItem: Hashable {
    func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }
}
