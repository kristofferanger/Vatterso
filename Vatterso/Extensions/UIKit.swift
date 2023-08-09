//
//  UIKit.swift
//  Vatterso
//
//  Created by Kristoffer Anger on 2023-07-13.
//

import UIKit

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
