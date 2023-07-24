//
//  Page.swift
//  Vatterso
//
//  Created by Kristoffer Anger on 2023-07-13.
//

import Foundation

struct Page: Codable, Identifiable {
    
    let id: Int
    let date, dateGmt, modified, modifiedGmt: String
    let title, guid, content, excerpt: Paragraph
    let author, featuredMedia: Int
    let parent, menuOrder: Int?
    let slug, status, type, link, commentStatus, pingStatus, template: String
    let links: Links
    
    enum CodingKeys: String, CodingKey {
        case id, date, dateGmt, modified, modifiedGmt, title, guid, content, excerpt, author, featuredMedia, parent, menuOrder, slug, status, type, link, commentStatus, pingStatus, template
        case links = "_links"
    }
    
    struct Paragraph: Codable {
        let rendered: String
        let protected: Bool?
    }
    
    struct Links: Codable {
        let wpAttachment: [Component]
        
        struct Component: Codable {
            let href: String
            let id: Int?
            let embeddable: Bool?
            let name: String?
            let templated: Bool?
        }
        
        enum CodingKeys: String, CodingKey {
            case wpAttachment = "wp:attachment" // wtf format
        }
    }
}

extension Page.Paragraph {
    // easy access of html stripped string
    var text: String {
        return self.rendered.htmlStripped()
    }
    
    var imageUrls: [String] {
        return self.rendered.htmlImageUrls()
    }
}
