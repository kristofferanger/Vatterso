//
//  SideBarItemPreferenceKey.swift
//  Vatterso
//
//  Created by Kristoffer Anger on 2023-08-08.
//

import Foundation
import SwiftUI

struct SideBarItemPreferenceKey: PreferenceKey {
    static var defaultValue: [SidebarItem] = []
    
    static func reduce(value: inout [SidebarItem], nextValue:() -> [SidebarItem]) {
        value += nextValue()
    }
}

struct SideBarItemViewModifier: ViewModifier {
    let item: SidebarItem
    @Binding var selection: SidebarItem?
    func body(content: Content) -> some View {
        content
            .opacity(selection == item ? 1 : 0)
            .preference(key: SideBarItemPreferenceKey.self, value: [item])
    }
}

extension View {
    func sideBarItem(_ item: SidebarItem, selection: Binding<SidebarItem?>) -> some View {
        self.modifier(SideBarItemViewModifier(item: item, selection: selection))
    }
}
