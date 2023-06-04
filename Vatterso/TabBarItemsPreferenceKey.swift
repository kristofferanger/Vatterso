//
//  TabBarItemsPreferenceKey.swift
//  Vatterso
//
//  Created by Kristoffer Anger on 2023-06-03.
//

import Foundation
import SwiftUI

struct TabBarItemsPreferenceKey: PreferenceKey {
    static var defaultValue: [VATabBarItem] = []
    
    static func reduce(value: inout [VATabBarItem], nextValue:() -> [VATabBarItem]) {
        value += nextValue()
    }
}

struct TabBarItemViewModifier: ViewModifier {
    let tab: VATabBarItem
    @Binding var selection: VATabBarItem
    func body(content: Content) -> some View {
        content
            .opacity(selection == tab ? 1 : 0)
            .preference(key: TabBarItemsPreferenceKey.self, value: [tab])
    }
}

extension View {
    func tabBarItem(_ item: VATabBarItem, selection: Binding<VATabBarItem>) -> some View {
        self.modifier(TabBarItemViewModifier(tab: item, selection: selection))
    }
}
