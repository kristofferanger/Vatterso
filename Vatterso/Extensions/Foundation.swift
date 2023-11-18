//
//  Foundation.swift
//  Vatterso
//
//  Created by Kristoffer Anger on 2023-07-13.
//

import Foundation
import SwiftUI


extension String {
    static let space = " "
    static let comma = ", "
    static let period = ". "
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

extension Binding where Value == Bool {
    init<Wrapped>(bindingOptional: Binding<Wrapped?>) {
        self.init(
            get: {
                bindingOptional.wrappedValue != nil
            },
            set: { newValue in
                guard newValue == false else { return }
                /// We only handle `false` booleans to set our optional to `nil`
                /// as we can't handle `true` for restoring the previous value.
                bindingOptional.wrappedValue = nil
            }
        )
    }
}

extension Binding {
    func mappedToBool<Wrapped>() -> Binding<Bool> where Value == Wrapped? {
        return Binding<Bool>(bindingOptional: self)
    }
}

extension Decodable {
    // failable init with a dictionary
    init?(dictionary: [String: Any]) {
        // this shouldn't normally fail though unless the dictionary contains corrupt data
        do {
            // try to serialize (dictionary to data)
            let data = try JSONSerialization.data(withJSONObject: dictionary, options: .fragmentsAllowed)
            
            do {
                // try to decode (data to object)
                let object = try JSONDecoder().decode(Self.self, from: data)
                self = object
            }
            catch {
                print("decoding error: \(error)")
                return nil
            }
        }
        catch {
            print("decoding error: \(error)")
            return nil
        }
    }
}

extension Encodable {
    var dictionaryEncoded: [String: Any] {
        // force unwrapping here because if self cannot be encoded as a dictionary
        // then something is very wrong with the data and the app should crash
        let dictionary = try! JSONSerialization.jsonObject(with: JSONEncoder().encode(self)) as! [String: Any]
        return dictionary
    }
}

extension NSObject {
    func propertyNames() -> [String] {
        let mirror = Mirror(reflecting: self)
        return mirror.children.compactMap{ $0.label }
    }
}

extension CodingUserInfoKey {
    static let managedObjectContext = CodingUserInfoKey(rawValue: "managedObjectContext")!
}

