//
//  SidebarItem.swift
//  Vatterso
//
//  Created by Kristoffer Anger on 2023-08-14.
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


struct SidebarItem: Identifiable {
    
    var pageType: PageType
    var items: [SidebarItem]?
    
    init(posts: [WPPost]) {
        self.pageType = .blog(posts)
    }
    
    init(page: WPPost, items: [SidebarItem]? = nil) {
        self.pageType = .page(page)
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
        // icons for pages
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

extension SidebarItem: Equatable {
    
    static func == (lhs: SidebarItem, rhs: SidebarItem) -> Bool {
        lhs.id == rhs.id
    }
}