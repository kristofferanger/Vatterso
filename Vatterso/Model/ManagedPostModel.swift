//
//  ManagedPostModel.swift
//  Vatterso
//
//  Created by Kristoffer Anger on 2023-10-23.
//

import Foundation
import SwiftUI
import CoreData

// Model for WordPress data
// same model is used for both pages and posts, the difference
// is that page also includes values for "parent" and "menuOrder"
@objc(Post)
class Post: NSManagedObject, Codable, Identifiable {

    @NSManaged var id: Int
    @NSManaged var date, dateGmt, modified, modifiedGmt: Date?
    @NSManaged var title, guid, content, excerpt: Section?
    @NSManaged var author, featuredMedia: Int
    @NSManaged var parent, menuOrder: NSNumber?
    @NSManaged var slug, status, type, link, commentStatus, pingStatus, template: String?
    @NSManaged var links: Links?
    @NSManaged var embedded: Embedded?
    
    enum CodingKeys: String, CodingKey {
        case id, date, dateGmt, modified, modifiedGmt, title, guid, content, excerpt, author, featuredMedia, parent, menuOrder, slug, status, type, link, commentStatus, pingStatus, template
        case links = "_links"
        case embedded = "_embedded"
    }
    
    // MARK: - Decodable
    required convenience init(from decoder: Decoder) throws {
        
        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext else {
            throw DecoderConfigurationError.missingManagedObjectContext
        }
        self.init(context: context)

        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(Int.self, forKey: .id)
        
        self.date = try container.decodeIfPresent(Date.self, forKey: .date)
        self.dateGmt = try container.decodeIfPresent(Date.self, forKey: .dateGmt)
        self.modified = try container.decodeIfPresent(Date.self, forKey: .modified)
        self.modifiedGmt = try container.decodeIfPresent(Date.self, forKey: .modifiedGmt)
        
        self.title = try container.decodeIfPresent(Section.self, forKey: .title)
        self.guid = try container.decodeIfPresent(Section.self, forKey: .guid)
        self.content = try container.decodeIfPresent(Section.self, forKey: .content)
        self.excerpt = try container.decodeIfPresent(Section.self, forKey: .excerpt)
        
        self.author = try container.decode(Int.self, forKey: .author)
        self.featuredMedia = try container.decode(Int.self, forKey: .featuredMedia)
        
        self.parent = try container.decodeIfPresent(Int.self, forKey: .parent) as NSNumber?
        self.menuOrder = try container.decodeIfPresent(Int.self, forKey: .menuOrder) as NSNumber?
        
        self.slug = try container.decodeIfPresent(String.self, forKey: .slug)
        self.status = try container.decodeIfPresent(String.self, forKey: .status)
        self.type = try container.decodeIfPresent(String.self, forKey: .type)
        self.link = try container.decodeIfPresent(String.self, forKey: .link)
        self.commentStatus = try container.decodeIfPresent(String.self, forKey: .commentStatus)
        self.pingStatus = try container.decodeIfPresent(String.self, forKey: .pingStatus)
        self.template = try container.decodeIfPresent(String.self, forKey: .template)
        
        self.links = try container.decodeIfPresent(Links.self, forKey: .links)
        self.embedded = try container.decodeIfPresent(Embedded.self, forKey: .embedded)
    }
    
    // MARK: - Encodable
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
    }
    
    @objc(Section)
    class Section: NSObject, Codable {
        var rendered: String
        var protected: Bool
    }
    
    @objc(Links)
    class Links: NSObject, Codable {
        var wpAttachment: [Component]
        
        class Component: NSObject, Codable {
            var href: String
            var id: Int
            var embeddable: Bool
            var name: String?
            var templated: Bool
        }
        
        enum CodingKeys: String, CodingKey {
            case wpAttachment = "wp:attachment" // wtf format
        }
    }
    
    @objc(Embedded)
    class Embedded: NSObject, Codable {
        var author:  [Author]
        
        class Author: NSObject, Codable, Identifiable {
            var id: Int
            var name: String?
        }
    }
}

extension Post {
    // easy access of the authors name
    var authorName: String? {
        return self.embedded?.author.first(where: { $0.id == self.author })?.name
    }
}

extension Post.Section {
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

enum DecoderConfigurationError: Error {
    case missingManagedObjectContext
}
