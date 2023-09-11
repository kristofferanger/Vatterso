//
//  WPPostModel.swift
//  Vatterso
//
//  Created by Kristoffer Anger on 2023-07-27.
//

import Foundation
import SwiftUI

// Model for WordPress data
// same model is used for both pages and posts, the difference
// is that page also includes values for "parent" and "menuOrder"
struct WPPost: Codable, Identifiable {
    
    let id: Int
    let date, dateGmt, modified, modifiedGmt: Date
    let title, guid, content, excerpt: Section
    let author, featuredMedia: Int
    let parent, menuOrder: Int? // page specific properties
    let slug, status, type, link, commentStatus, pingStatus, template: String
    let links: Links
    let embedded: Embedded?
    
    enum CodingKeys: String, CodingKey {
        case id, date, dateGmt, modified, modifiedGmt, title, guid, content, excerpt, author, featuredMedia, parent, menuOrder, slug, status, type, link, commentStatus, pingStatus, template
        case links = "_links"
        case embedded = "_embedded"
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
    
    struct Embedded: Codable {
        let author:  [Author]
        
        struct Author: Codable, Identifiable {
            let id: Int?
            let name: String?
        }
    }
}

extension WPPost {
    // easy access of the authors name
    var authorName: String? {
        return self.embedded?.author.first(where: { $0.id == self.author })?.name
    }
}

extension WPPost.Section {
    // easy access of html stripped string
    var text: String {
        return self.rendered.htmlStripped()
    }
    // string with html tags replaced with markdown
    var markdownText: String {
        return self.rendered.htmlToMarkDown()
    }
    // text processed into paragraphs
    var paragraphs: [WPParagraph] {
        let result = self.rendered.makeParagraphs()
        return result
    }
}


/// A block-level element always starts on a new line, and the browsers automatically add some space (a margin) before and after the element.
/// A block-level element always takes up the full width available (stretches out to the left and right as far as it can).
/// Two commonly used block elements are: <p> and <div>.

struct WPBlock: Identifiable {
    let id: String
    var text: String?
    var font: Font?
    var color: Color?
    var weight: Font.Weight?
    var imageUrl: URL?
}

struct WPParagraph: Identifiable {
    let id = UUID().uuidString
    var text: String?
    var font: Font?
    var color: Color?
    var weight: Font.Weight?
    var imageUrl: URL?
}

extension URL {
    init?(optionalString: Optional<String>) {
        guard let string = optionalString else { return nil }
        self.init(string: string)
    }
}

