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

    /// The selected item (page) on the side bar
    @Binding var selection: SidebarItem?
    
    /// Creates an instance that selects from content associated with
    /// `Selection` values.
    init(selection: Binding<SidebarItem?>? = nil, @ViewBuilder content: @escaping (Binding<Bool>) -> Content) {
        self._selection = selection ?? .constant(nil)
        self.content = content
    }

    var body: some View {
        ZStack {
            // passing showingSideBar to content so that pages use it
            content($showingSideBar)
            //  passing showingSideBar to SidebarMenu to handle the transision
            SidebarMenu(isShowing: $showingSideBar) {
                // passing showingSideBar to SideMenuView so it can be dismissed
                // also passing items and selection of obvious reasons
                // - since here is where the selection is taking place
                SideMenuView(tabs: $items, selectedTab: $selection, showingSideMenu: $showingSideBar)
            }
        }
        .onPreferenceChange(SidebarItemsPreferenceKey.self) { value in
            // getting items with preference key,
            // ie when they are added to the layout
            self.items = value
        }
    }
    
    // private stuff
    private var content: (_ showSideBar: Binding<Bool>) -> Content
    @State private var items: [SidebarItem] = []
    @State private var showingSideBar: Bool = false
}


struct SidebarView2<Content: View>: View {

    init(items: [SidebarItem], @ViewBuilder content: @escaping((SidebarItem?, Binding<Bool>)) -> Content) {
        self._items = State(wrappedValue: items)
        self._selection = State(wrappedValue: items.first)
        self.content = content
    }
    
    var body: some View {
        ZStack {
            // passing showingSideBar to content so that pages use it
            content((selection, $showingSidebar))
            //  passing showingSideBar to SidebarMenu to handle the transision
            SidebarMenu(isShowing: $showingSidebar) {
                // passing showingSideBar to SideMenuView so it can be dismissed
                // also passing items and selection of obvious reasons
                // - since here is where the selection is taking place
                SideMenuView(tabs: $items, selectedTab: $selection, showingSideMenu: $showingSidebar)
            }
        }
    }
    
    // private stuff
    @State private var items: [SidebarItem]
    @State private var selection: SidebarItem?
    @State private var showingSidebar: Bool = false
    private var content: ((SidebarItem?, Binding<Bool>)) -> Content
}
