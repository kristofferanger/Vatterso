//
//  SideBar.swift
//  Vatterso
//
//  Created by Kristoffer Anger on 2023-08-08.
//

import SwiftUI

struct SideBar<Content>: View where Content: View {

    @Binding var selection: VASideBarItem?
    @State private var items: [VASideBarItem] = []
    @State private var showingSideBar: Bool = false
    
    private var content: (_ showSideBar: Binding<Bool>) -> Content
    
    var body: some View {
        ZStack() {
            content($showingSideBar)
            SidebarMenu(isShowing: $showingSideBar) {
                SideMenuView(tabs: $items, selectedTab: $selection, showingSideMenu: $showingSideBar)
            }
        }
        .onPreferenceChange(SidebarItemPreferenceKey.self) { value in
            // getting items with preference key
            self.items = value
        }
    }
    
    /// Creates an instance that selects from content associated with
    /// `Selection` values.
    init(selection: Binding<VASideBarItem?>, @ViewBuilder content: @escaping (Binding<Bool>) -> Content) {
        self._selection = selection
        self.content = content
    }
}

//struct SideBar_Previews: PreviewProvider {
//    static var previews: some View {
//        SideBar()
//    }
//}
