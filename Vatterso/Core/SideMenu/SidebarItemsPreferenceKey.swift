//
//  SidebarPreferenceKey.swift
//  Vatterso
//
//  Created by Kristoffer Anger on 2023-08-16.
//

import Foundation
import SwiftUI


struct SidebarLabelsPreferenceKey: PreferenceKey {
    static var defaultValue: [Text] = []
    
    static func reduce(value: inout [Text], nextValue:() -> [Text]) {
        value += nextValue()
    }
}

struct SidebarItemsPreferenceKey: PreferenceKey {
    static var defaultValue: [SidebarItem] = []
    
    static func reduce(value: inout [SidebarItem], nextValue:() -> [SidebarItem]) {
        value += nextValue()
    }
}

struct SidebarLabelViewModifier: ViewModifier {
    var label: Text
    func body(content: Content) -> some View {
        content
            .preference(key: SidebarLabelsPreferenceKey.self, value: [label])
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
    
    func sideBarLabel(@ViewBuilder  _ label: () -> Text) -> some View {
        self.modifier(SidebarLabelViewModifier(label: label()))
    }
    

    func sideBarItem(_ item: SidebarItem, selection: Binding<SidebarItem?>) -> some View {
        self.modifier(SidebarItemViewModifier(item: item, selection: selection))
    }
}

