//
//  SideBarItemPreferenceKey.swift
//  Vatterso
//
//  Created by Kristoffer Anger on 2023-08-08.
//

import Foundation
import SwiftUI

struct SidebarItemPreferenceKey: PreferenceKey {
    static var defaultValue: [VASideBarItem] = []
    
    static func reduce(value: inout [VASideBarItem], nextValue:() -> [VASideBarItem]) {
        value += nextValue()
    }
}

struct SideBarItemViewModifier: ViewModifier {
    let item: VASideBarItem
    @Binding var selection: VASideBarItem?
    func body(content: Content) -> some View {
        content
            .opacity(selection == item ? 1 : 0)
            .preference(key: SidebarItemPreferenceKey.self, value: [item])
    }
}

extension View {
    func sideBarItem(_ item: VASideBarItem, selection: Binding<VASideBarItem?>) -> some View {
        self.modifier(SideBarItemViewModifier(item: item, selection: selection))
    }
}
