//
//  Foundation.swift
//  Vatterso
//
//  Created by Kristoffer Anger on 2023-07-13.
//

import Foundation
import RegexBuilder
import SwiftUI

extension String {
    
    func trimmed() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    func htmlStripped() -> String {
        let pattern = "<[^>]+>"
        let stripped = self.trimmed().replacingOccurrences(of: pattern, with: "", options: .regularExpression, range: nil)
        return stripped
    }
    
    func htmlImageUrls() -> [String] {
        let pattern = "(http[^\\s]+(jpg|jpeg|png|tiff)\\b)"
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let nsString = self as NSString
            let results = regex.matches(in: self, range: NSMakeRange(0, nsString.length))
            return results.map { nsString.substring(with: $0.range)}
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
    // Replace HTML comments, in the format <!-- ... comment ... -->
    func removeComments() -> String {
        var text = self
        var loop = true

        // Stop looking for comments when none is found
        while loop {
            
            // Retrieve hyperlink
            let searchComment = Regex {
                Capture {
                    // A comment in HTML starts with:
                    "<!--"
                    ZeroOrMore(.any, .reluctant)
                    // A comment in HTML ends with:
                    "-->"
                }
            }
            if let match = text.firstMatch(of: searchComment) {
                let (_, comment) = match.output
                text = text.replacing(comment, with: "")
            } else {
                loop = false
            }
        }
        return text
    }
    
    // replacing all substrings with one string
    func replace(substrings: [String], with string: String) -> String {
        var text = self
        for substring in substrings {
            text = text.replacing(substring, with: string)
        }
        return text
    }
    
    // Replace hyperlinks block
    func replaceHyperlinks() -> String {
        var text = self
        var loop = true
        // Stop looking for hyperlinks when none is found
        while loop {
            // Retrieve hyperlink
            let searchHyperlink = Regex {
                // A hyperlink that is embedded in an HTML tag in this format: <a... href="<hyperlink>"....>
                "<a"
                // There could be other attributes between <a... and href=...
                // .reluctant parameter: to stop matching after the first occurrence
                ZeroOrMore(.any)
                
                // We could have href="..., href ="..., href= "..., href = "...
                "href"
                ZeroOrMore(.any)
                "="
                ZeroOrMore(.any)
                "\""
                // Here is where the hyperlink (href) is captured
                Capture {
                    ZeroOrMore(.any)
                }
                "\""
                // After href="<hyperlink>", there could be a ">" sign or other attributes
                ZeroOrMore(.any)
                ">"
                // Here is where the linked text is captured
                Capture {
                    ZeroOrMore(.any, .reluctant)
                }
                One("</a>")
            }.repetitionBehavior(.reluctant)
            
            if let match = text.firstMatch(of: searchHyperlink) {
                let (hyperlinkTag, href, content) = match.output
                let markDownLink = "[" + content + "](" + href + ")"
                text = text.replacing(hyperlinkTag, with: markDownLink)
            } else {
                loop = false
            }
        }
        return text
    }
    
    func createParagraphs() -> [WPParagraph] {
        
        func processString(string: String, paragraphs: [WPParagraph]) -> [WPParagraph] {
            // try matching paragraphs, starts with a "<p>"  or "<p style...>"and ends with a "</p>"
            let paragraph = Regex {
                ChoiceOf {
                    "<p"
                    "<h2"
                    "<figure"
                }
                ZeroOrMore(.any)
                // font size is captured (optional)
                Optionally {
                    "style"
                    ZeroOrMore(.any)
                    // font size starts with font-size and :
                    "font-size:"
                    // capture size
                    Capture {
                        ZeroOrMore(.any)
                    }
                    // size ends with px
                    "px"
                    // could include other styles too
                    ZeroOrMore(.any)
                }
                ">"
                // image url is captured (optional)
                Optionally {
                    "[<"
                    ZeroOrMore(.any)
                    ">]("
                    // url is captured
                    Capture {
                        ZeroOrMore(.any)
                    }
                    ")"
                }
                // text is captured
                Capture {
                    ZeroOrMore(.any)
                }
                // text ends just before end mark </p>
                ChoiceOf {
                    "</p>"
                    "</h2>"
                    "</figure>"
                }
            }.repetitionBehavior(.reluctant)
            
            if let match = string.firstMatch(of: paragraph) {
                let (paragraph, fontSize, imageUrl, text) = match.output
                
                var font: Font
                if let fontSize, let size = Float(fontSize) {
                    font = Font.system(size: CGFloat(size))
                }
                else {
                    font = Font.body
                }
                
                var url: String
                if let imageUrl {
                    print(imageUrl)
                }
                
                // call method recursively until all matches are found
                return processString(string: string.replacing(paragraph, with: ""), paragraphs: paragraphs + [WPParagraph(text: String(text), font: font)])
            }
            else {
                // return created paragraphs
                return paragraphs
            }
        }

        return processString(string: self, paragraphs: [WPParagraph]())
    }
    
    func htmlToMarkDown() -> String {
        return self.removeComments() // remove comments like "<!-- ... comment ... -->"
            .replace(substrings: ["\n", "</div>"], with: "")  // replace tags with nothing
            .replace(substrings: ["<div>"], with: "\n") // add linebreak
            .replace(substrings: ["<br>"], with: "\n") // add linebreak with inset

            .replace(substrings: ["<strong>", "</strong>", "<b>", "</b>"], with: "**") // add bold text
            .replace(substrings: ["<em>", "</em>", "<i>", "</i>"], with: "*") // add italic text
            .replaceHyperlinks() // replace pattern <a... href="<hyperlink>"....> with [content](href)

    }
}

extension Date {
    func dateSting() -> String {
        let relativeDateFormatter = DateFormatter()
        relativeDateFormatter.timeStyle = .none
        relativeDateFormatter.dateStyle = .medium
        relativeDateFormatter.doesRelativeDateFormatting = true
        return relativeDateFormatter.string(from: self)
    }
}
