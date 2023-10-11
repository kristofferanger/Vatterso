//
//  SidebarPreferenceKey.swift
//  Vatterso
//
//  Created by Kristoffer Anger on 2023-08-16.
//

import Foundation
import SwiftUI


struct CustomPreferenceKey<Content: View>: PreferenceKey {
    static var defaultValue: [Content] { get { [Content]() } }
    
    static func reduce(value: inout [Content], nextValue: () -> [Content]) {
        value += nextValue()
    }
}

struct SidebarItemsPreferenceKey: PreferenceKey {
    static var defaultValue: [SidebarItem] = []
    
    static func reduce(value: inout [SidebarItem], nextValue:() -> [SidebarItem]) {
        value += nextValue()
    }
}

struct SidebarLabelViewModifier<T: View>: ViewModifier {
    var id: Int
    var label: T

    func body(content: Content) -> some View {
        content
            .preference(key: CustomPreferenceKey.self, value: [label])
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
    
    func sideBarLabel(selectedId id: Int, @ViewBuilder  _ label: @escaping () -> some View) -> some View {
        self.modifier(SidebarLabelViewModifier(id: id, label: label()))
    }

    func sideBarItem(_ item: SidebarItem, selection: Binding<SidebarItem?>) -> some View {
        self.modifier(SidebarItemViewModifier(item: item, selection: selection))
    }
}

