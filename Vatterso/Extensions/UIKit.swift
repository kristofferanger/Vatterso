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
