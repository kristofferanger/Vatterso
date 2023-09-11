//
//  String+regex.swift
//  Vatterso
//
//  Created by Kristoffer Anger on 2023-08-09.
//

import RegexBuilder // NEW! iOS 16 stuff
import SwiftUI
import SwiftSoup

extension String {
    
    func trimmed() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    // simple method to remove all tags
    func htmlStripped() -> String {
        let pattern = "<[^>]+>"
        let stripped = self.trimmed().replacingOccurrences(of: pattern, with: "", options: .regularExpression, range: nil)
        return stripped
    }
    
    // Replace non essential HTML sections, eg comments in the format <!-- ... comment ... -->
    func removeBetween(prefix: String, suffix: String) -> String {
        var text = self
        var loop = true

        // Stop looking when none is found
        while loop {
            // get section
            let searchTag = Regex {
                Capture {
                    // start of html tag
                    prefix
                    ZeroOrMore(.any, .reluctant)
                    //end of html tag
                    suffix
                }
            }
            if let match = text.firstMatch(of: searchTag) {
                let (_, comment) = match.output
                text = text.replacing(comment, with: "")
            } else {
                loop = false
            }
        }
        return text
    }
    
    // replacing all substrings, ex ["<div>", "<br>"] with "\n"
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
    
    // split text into paragraphs with text, font, color and image
    // using SwiftSoup library
    func makeParagraphs() -> [WPParagraph] {
        
        var paragraphs = [WPParagraph]()
        // create docoument, focus on the body part
        guard let doc: Document = try? SwiftSoup.parseBodyFragment(self), let body = doc.body() else { return paragraphs }
        
        for element in body.children() {
            
            var font: Font?
            var color: Color?
            
            let texts: [String] = element.getChildNodes().compactMap { node in
                                
                // nodes that is an Element contains some kind of modifier
                if let element = node as? SwiftSoup.Element, let text = try? element.text() {
                    // ignore scripts
                    guard element.tagName() != "script" else { return nil }
                    
                    
                    if element.tagName() == "br" {
                        return "\n"
                    }
                    
                    if element.tagName() == "strong" {
                        return "**\(text)**"
                    }
                    
                    if element.tagName() == "em" {
                        return "*\(text)*"
                    }
                    
                    if element.tagName() == "li" {
                        return "• \(text)\n"
                    }
                    
                    if element.tagName() == "a", let href = try? element.attr("href") {
                        return "[\(text)](\(href))"
                    }

                    if element.tagName() == "span", let style = try? element.attr("style") {
                        (font, color) = style.findFontAndColor()
                        return "\(text)"
                    }
                    
                    if element.tagName() == "img" {
                        let src = try? element.attr("src")
                        paragraphs.append(WPParagraph(imageUrl: URL(optionalString: src)))
                        return nil
                    }
                    
                    // tag is missing
                    print("WARNING: Tag is not parsed ")
                    print("tag: \(element.tagName())")
                    print("style: \(try? element.attr("style"))")
                    print("text: \(try? element.text())")
                }
                // node contains only text, so return it
                else if let textNode = node as? TextNode {
                    return textNode.text()
                }

                return nil
            }
            paragraphs.append(WPParagraph(text: texts.joined(), font: font, color: color))
        }
        return paragraphs
    }
    
    func findFontAndColor() -> (font: Font?, color: Color?) {
        
        var font: Font?
        var color: Color?
        
        for style in self.split(separator: ";") {
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
    
    
    // split text into paragraphs with text, font, color and image
    // using regex builder
    @available(*, deprecated, message: "use 'makeParagraphs()' instead")
    func createParagraphs() -> [WPParagraph] {
        
        func processString(string: String, paragraphs: [WPParagraph]) -> [WPParagraph] {
            // try matching paragraphs, starts with a "<p>", "<p style...>" and ends with a "</p>"
            let paragraphRegex = Regex {
                ChoiceOf {
                    /<p>.{0,}<span/
                    "<p"
                    "<h2"
                    "<figure"
                }
                ZeroOrMore(.any)
                // color or font is captured (optional)
                Optionally {
                    "style"
                    // step forward
                    OneOrMore(.any)
                    // try capture color
                    Optionally {
                        "color:"
                        ZeroOrMore( .whitespace)
                        // capture size
                        TryCapture {
                            ZeroOrMore(.any)
                        } transform: {
                            String($0)
                        }
                        ";"
                        ZeroOrMore(.any)
                    }
                    // font size starts with font-size:
                    "font-size:"
                    ZeroOrMore( .whitespace)
                    // capture size
                    TryCapture {
                        ZeroOrMore(.any)
                    } transform: {
                        Float($0)
                    }
                    // size ends with px or pt
                    "p"
                    // could include other styles too
                    ZeroOrMore(.any)
                }
                // end of initial tag
                ">"
                // capture either image url or text
                ChoiceOf {
                    // image url is captured (optional)
                    Optionally {
                        "[<img"
                        OneOrMore(.any)
                        ">]"
                        // url is captured
                        "("
                        Capture {
                            OneOrMore(.any)
                        }
                        ")"
                    }
                    // text is captured
                    Capture {
                        ZeroOrMore(.any)
                    } transform: {
                        String($0)
                    }
                }
                // text ends right before end mark, ex </p>
                Optionally {
                    "</span>"
                    ZeroOrMore(.any)
                }
                ChoiceOf {
                    "</p>"
                    "</h2>"
                    "</figure>"
                }
            }.repetitionBehavior(.reluctant)
            
            // get first match
            if let match = string.firstMatch(of: paragraphRegex) {
                let (paragraph, textColor, fontSize, imageUrl, text) = match.output
                
                // handle font
                var font: Font
                if let fontSize {
                    font = Font.system(size: CGFloat(fontSize + 5))
                }
                else {
                    font = Font.body
                }
                
                // handle color
                var color: Color? = nil
                if let textColor, let wrappedValue = textColor {
                    color = Color.hex(wrappedValue)
                }
                
                // handle url
                var url: URL? = nil
                if let imageUrl, let wrappedValue = imageUrl {
                    url = URL(string: String(wrappedValue))
                }
                // create paragraph
                let newParagraph = WPParagraph(text: text, font: font, color: color, imageUrl: url)
   
                // call method recursively (with match removed) until all matches are found
                return processString(string: string.replacing(paragraph, with: ""), paragraphs: paragraphs + [newParagraph])
            }
            else {
                // return list of created paragraphs
                return paragraphs
            }
        }
        // start recusion with self as input
        return processString(string: self, paragraphs: [WPParagraph]())
    }
    
    // translate html tags to markdown text
    func htmlToMarkDown() -> String {
        return self
        // cleaning string
            .removeBetween(prefix:"<!--", suffix: "-->") // remove comments
            .removeBetween(prefix:"<script", suffix: "/script>") // remove java scripts
            .replace(substrings: ["\n", "</div>"], with: "")  // replace elements with blanks
            .replace(substrings: ["<div>", "<br>", "<br />"], with: "\n") // add linebreak
        // text modifiers
            .replace(substrings: ["<strong>", "</strong>", "<b>", "</b>"], with: "**") // add bold text
            .replace(substrings: ["<em>", "</em>", "<i>", "</i>"], with: "*") // add italic text
            .replaceHyperlinks() // replace pattern <a... href="<hyperlink>"....> with [content](href)
    }
}
