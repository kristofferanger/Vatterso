//
//  WPPostModel.swift
//  Vatterso
//
//  Created by Kristoffer Anger on 2023-07-27.
//

import Foundation
import SwiftUI
import SwiftSoup

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
        let result = self.rendered.htmlToMarkDown().createParagraphs()
        return result
    }
    
    var blocks: [WPBlock] {
        
        var blocks = [WPBlock]()
        
        guard let doc: Document = try? SwiftSoup.parseBodyFragment(self.rendered), let body = doc.body() else { return [] }
    
        
        for element in body.children() {
            
            var font: Font?
            var color: Color?
            
            let texts: [String] = element.getChildNodes().compactMap { node in
                                
                // node contains some kind of modifier
                if let element = node as? Element {
                    // get text
                    let text = try? element.text()
                    
                    if element.tagName() == "a",
                       let text,
                       let href = try? element.attr("href")
                    {
                        return "[\(text)](\(href))"
                    }
                    
                    if element.tagName() == "br" {
                        return "\n"
                    }
                    
                    if element.tagName() == "strong",
                       let text
                    {
                        return "**\(text)**"
                    }
                    if element.tagName() == "em",
                       let text
                    {
                        return "*\(text)*"
                    }
                    
                    if element.tagName() == "span",
                       let style = try? element.attr("style"),
                       let text
                    {
                        (font, color) = getFontAndColorFromStyle(style)
                        return "\(text)"
                    }
                    
                    print("tag: \(element.tagName())")
                    print("style: \(try? element.attr("style"))")
                    print("text: \(try? element.text())")
                    print("hep")
                    
                }
                // node contains only text, so return it
                else if let textNode = node as? TextNode {
                    return textNode.text()
                }

                return nil
            }
            let text = texts.joined()
            blocks.append(WPBlock(id: UUID().uuidString, text: text, font: font, color: color))
        }
        
//        let children = doc.children()
//
//        let paragraphs = (try? body.getElementsByTag("p"))!
//
//        for element in paragraphs  {
//            let bodyAttributes = element.getAttributes()
//            print(try? bodyAttributes!.toString() ?? "meck")
//            for childNode in element.children()  {
//                if let text = try? childNode.text() {
//                    blocks.append(WPBlock(id: childNode.id(), text: text))
//                }
//            }
//
//        }
        return blocks
    }
    
    var testText: [WPBlock] {
        guard let doc: Document = try? SwiftSoup.parse(self.rendered) else { return [] }
        guard let txt = try? doc.text() else { return [] }
        guard let elements = try? doc.getAllElements() else { return [] }
        for element in elements {
            print(element.tagName())
            
            let attributes = element.getAttributes()
            for attribute in attributes! {
                print("Attribute: \(attribute.toString())")
            }

            for textNode in element.textNodes() {
                print(textNode.text())
                print("*")
            }
        }
        
        return [WPBlock(id: "sdfasdfa", text: txt)]
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



private func getFontAndColorFromStyle(_ string: String) -> (font: Font?, color: Color?) {
    
    var font: Font?
    var color: Color?
    
    for style in string.split(separator: ";") {
        let keysAndValues = style.split(separator: ":").map{ $0.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) }
        guard let key = keysAndValues.first, let value = keysAndValues.last else { continue }
        
        if key == "font-size", let size = Int(value.trimmingCharacters(in: CharacterSet.decimalDigits.inverted)) {
            font = Font.system(size: CGFloat(size) * 1.6)
        }
        if key == "color" {
            color = Color.hex(value)
        }
    }
    return (font, color)

}
