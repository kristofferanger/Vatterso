//
//  SidebarView.swift
//  Vatterso
//
//  Created by Kristoffer Anger on 2023-08-14.
//

import SwiftUI

struct SidebarView<Content: View>: View {

    @Binding var selection: SidebarItem?
    @State private var items: [SidebarItem] = []
    @State private var showingSideBar: Bool = false
    
    private var content: (_ showSideBar: Binding<Bool>) -> Content
    
    var body: some View {
        ZStack() {
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
        .onPreferenceChange(SideBarItemPreferenceKey.self) { value in
            // getting items with preference key,
            // ie when they are added to the layout
            self.items = value
        }
    }
    
    /// Creates an instance that selects from content associated with
    /// `Selection` values.
    init(selection: Binding<SidebarItem?>, @ViewBuilder content: @escaping (Binding<Bool>) -> Content) {
        self._selection = selection
        self.content = content
    }
}
