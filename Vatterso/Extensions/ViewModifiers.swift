//
//  ViewModifiers.swift
//  Vatterso
//
//  Created by Kristoffer Anger on 2023-08-18.
//

import Foundation
import SwiftUI

struct NavigationStackModifier<Item, Destination: View>: ViewModifier {
    let item: Binding<Item?>
    let destination: (Item) -> Destination

    func body(content: Content) -> some View {
        
        content.background( NavigationLink(isActive: item.mappedToBool() ) {
            if let item = item.wrappedValue {
                destination(item)
            } else {
                EmptyView()
            }
        } label: {
            EmptyView()
        })
    }
}

extension View {
    func navigationDestination<Item, Destination: View>(for binding: Binding<Item?>, @ViewBuilder destination: @escaping (Item) -> Destination ) -> some View {
        self.modifier(NavigationStackModifier(item: binding, destination: destination))
    }
}
