//
//  SidebarView.swift
//  Vatterso
//
//  Created by Kristoffer Anger on 2023-08-14.
//

import SwiftUI

/// A view that switches between multiple child views using interactive user
/// interface elements.
///
/// To create a user interface with a sidebar with tabs, place views in a `SidebarView` and apply
/// the ``View/sideBarItem(_ ::)`` modifier to the contents of each tab.
///
/// The following example creates a tab view with three tabs, each presenting a
/// custom child view. The first tab has a numeric badge and the third has a
/// string badge.
///
///     SidebarView {
///         ReceivedView()
///             .sideBarItem(sideBarItem, selection: $selection)
///         SentView()
///             .sideBarItem {
///                 Label("Sent", systemImage: "tray.and.arrow.up.fill")
///             }
///     }

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

    init(viewModel: SidebarViewModel, @ViewBuilder content: @escaping((SidebarItem, Binding<Bool>)) -> Content) {
        self.content = content
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    private var homePage: SidebarItem {
        return SidebarItem(posts: [])
    }
    
    var body: some View {
        ZStack {
            // passing showingSideBar to content so that pages use it
            content((selection ?? homePage, $showingSidebar))
            //  passing showingSideBar to SidebarMenu to handle the transision
            SidebarMenu(isShowing: $showingSidebar) {
                // passing showingSideBar to SideMenuView so it can be dismissed
                // also passing items and selection of obvious reasons
                // - since here is where the selection is taking place
                SideMenuView(tabs: $items, selectedTab: $selection, showingSideMenu: $showingSidebar)
            }
            .onReceive(viewModel.$items, perform: { items in
                if let firstItem = items.first {
                    selection = firstItem
                }
                self.items = items
            })
        }
    }
    
    // private stuff
    @StateObject var viewModel: SidebarViewModel
    @State private var items: [SidebarItem] = []
    @State private var selection: SidebarItem?
    @State private var showingSidebar: Bool = false
    private var content: ((SidebarItem, Binding<Bool>)) -> Content
}
