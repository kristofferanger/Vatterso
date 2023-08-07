//
//  WPPostModel.swift
//  Vatterso
//
//  Created by Kristoffer Anger on 2023-07-27.
//

import Foundation
import SwiftUI

// Model for WordPress site data
// same model is used for both page and post, the difference
// is that page also includes values for "parent" and "menuOrder"

struct WPPost: Codable, Identifiable {
    
    let id: Int
    let date, dateGmt, modified, modifiedGmt: String
    let title, guid, content, excerpt: Section
    let author, featuredMedia: Int
    let parent, menuOrder: Int?
    let slug, status, type, link, commentStatus, pingStatus, template: String
    let links: Links
    
    enum CodingKeys: String, CodingKey {
        case id, date, dateGmt, modified, modifiedGmt, title, guid, content, excerpt, author, featuredMedia, parent, menuOrder, slug, status, type, link, commentStatus, pingStatus, template
        case links = "_links"
    }
    
    struct Section: Codable {
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

extension WPPost.Section {
    // easy access of html stripped string
    var text: String {
        return self.rendered.htmlStripped()
    }
    
    var markdownText: String {
        return self.rendered.htmlToMarkDown()
    }
    
    var paragraphs: [WPParagraph] {
        let result = self.rendered.htmlToMarkDown().createParagraphs()
        return result
    }
}

struct WPParagraph: Identifiable {
    let id = UUID().uuidString
    var text: String?
    var font: Font?
    var color: Color?
    var imageUrl: URL?
}
