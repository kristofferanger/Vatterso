//
//  SidebarView.swift
//  Vatterso
//
//  Created by Kristoffer Anger on 2023-08-14.
//

import SwiftUI

/// A view that switches between multiple child views using interactive user
/// interface elements.

struct SidebarView<Content: View>: View {
    
    init(items: [SidebarItem] = [], @ViewBuilder content: @escaping((Binding<SidebarItem?>, Binding<Bool>)) -> Content) {
        self._items = State(wrappedValue: items)
        self._selection = State(wrappedValue: items.first)
        self.content = content
    }
    
    var body: some View {
        ZStack {
            // passing showingSideBar to content so that pages use it
            content(($selection, $showingSidebar))
            //  passing showingSideBar to SidebarMenu to handle the transision
            SidebarMenu(isShowing: $showingSidebar) {
                // passing showingSideBar to SideMenuView so it can be dismissed
                // also passing items and selection of obvious reasons
                // - since here is where the selection is taking place
                SideMenuView(tabs: $items, selectedTab: $selection, showingSideMenu: $showingSidebar)
            }
        }
        .onPreferenceChange(SidebarItemsPreferenceKey.self) { value in
            // getting items with preference key,
            // ie when they are added to the layout
            if let selection = value.first {
                self.selection = selection
                self.items = value
            }
        }
    }
    
    // private stuff
    @State private var items: [SidebarItem]
    @State private var selection: SidebarItem?
    @State private var showingSidebar: Bool = false
    private var content: ((Binding<SidebarItem?>, Binding<Bool>)) -> Content
}
