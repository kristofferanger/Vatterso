//
//  SidebarPreferenceKey.swift
//  Vatterso
//
//  Created by Kristoffer Anger on 2023-08-16.
//

import Foundation
import SwiftUI


struct SidebarItemsPreferenceKey: PreferenceKey {
    static var defaultValue: [SidebarItem] = []
    
    static func reduce(value: inout [SidebarItem], nextValue:() -> [SidebarItem]) {
        value += nextValue()
    }
}

struct SidebarLabelViewModifier: ViewModifier {
    var label: any View
    func body(content: Content) -> some View {
        content
            //.preference(key: SidebarLabelsPreferenceKey.self, value: [label])
    }
}


struct SidebarItemViewModifier: ViewModifier {
    let item: SidebarItem
    @Binding var selection: SidebarItem?
    func body(content: Content) -> some View {
        content
            .opacity(item.tabId == selection?.tabId ? 1 : 0)
            .preference(key: SidebarItemsPreferenceKey.self, value: [item])
    }
}

extension View {
    
    func sideBarLabel(@ViewBuilder  _ label: () -> some View) -> some View {
        self.modifier(SidebarLabelViewModifier(label: label()))
    }

    func sideBarItem(_ item: SidebarItem, selection: Binding<SidebarItem?>) -> some View {
        self.modifier(SidebarItemViewModifier(item: item, selection: selection))
    }
}

