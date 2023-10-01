//
//  UIKit.swift
//  Vatterso
//
//  Created by Kristoffer Anger on 2023-07-13.
//

import UIKit
import SwiftUI

extension UIScreen {
    static var safeArea: UIEdgeInsets {
        let keyWindow = UIApplication.shared.connectedScenes
            .filter{ $0.activationState == .foregroundActive }
            .map{ $0 as? UIWindowScene }
            .compactMap{ $0 }
            .first?.windows
            .filter{ $0.isKeyWindow }.first
        
        return keyWindow?.safeAreaInsets ?? .zero
    }
}

extension Color {
    static func hex(_ hex: String) -> Color {
        let scanner = Scanner(string: hex.description.trimmingCharacters(in: CharacterSet.alphanumerics.inverted))
        var hexNumber: UInt64 = 0
        var r: CGFloat = 0.0, g: CGFloat = 0.0, b: CGFloat = 0.0

        let result = scanner.scanHexInt64(&hexNumber)
        if result {
            r = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
            g = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
            b = CGFloat(hexNumber & 0x000000ff) / 255
        }
        return Color(red: r, green: g, blue: b)
    }
}


extension UIView {
    
    // In order to create computed properties for extensions, we need a key to
    // store and access the stored property
    fileprivate struct AssociatedObjectKeys {
        static var tapGestureRecognizer = "MediaViewerAssociatedObjectKey_mediaViewer"
    }
    
    // Set our computed property type to a closure
    fileprivate var gestureRecognizerAction: ((UIGestureRecognizer) -> Void)? {
        set {
            if let newValue {
                // Computed properties get stored as associated objects
                objc_setAssociatedObject(self, &AssociatedObjectKeys.tapGestureRecognizer, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            }
        }
        get {
            let gestureRecognizerActionInstance = objc_getAssociatedObject(self, &AssociatedObjectKeys.tapGestureRecognizer) as? ((UIGestureRecognizer) -> Void)
            return gestureRecognizerActionInstance
        }
    }
    
    // This is the meat of the sauce, here we create the tap gesture recognizer and
    // store the closure the user passed to us in the associated object we declared above
    public func addGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer? = nil, action: ((UIGestureRecognizer) -> Void)?) {
        self.isUserInteractionEnabled = true
        self.gestureRecognizerAction = action
        
        let gesture: UIGestureRecognizer
        
        if let gestureRecognizer {
            gesture = gestureRecognizer
            gesture.removeTarget(nil, action: nil)
            gesture.addTarget(self, action: #selector(handleGesture))
        }
        else {
            gesture = UITapGestureRecognizer(target: self, action: #selector(handleGesture))
        }
        self.addGestureRecognizer(gesture)
    }
    
    // Every time the user taps on the UIImageView, this function gets called,
    // which triggers the closure we stored
    @objc fileprivate func handleGesture(sender: UIGestureRecognizer) {
        if let action = self.gestureRecognizerAction {
            action(sender)
        } else {
            // no action
        }
    }
    
}

extension UINavigationController {
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        // add any custom navigation bar appearance here
        /*
        let compactAppearance = UINavigationBarAppearance()
        compactAppearance.backgroundColor = .green
        navigationBar.compactAppearance = compactAppearance

        navigationBar.standardAppearance = {
            let standardAppearance = UINavigationBarAppearance()
            standardAppearance.backgroundColor = .black
            standardAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            return standardAppearance
        }()
        navigationBar.scrollEdgeAppearance = {
            let appearance = UINavigationBarAppearance()
            appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            return appearance
        }()
         */
        
    }
}
