//
//  Foundation.swift
//  Vatterso
//
//  Created by Kristoffer Anger on 2023-07-13.
//

import Foundation

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
