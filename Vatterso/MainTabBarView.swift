//
//  MainTabBarView.swift
//  Vatterso
//
//  Created by Kristoffer Anger on 2023-06-01.
//

import SwiftUI

struct MainTabBarView: View {

    @StateObject private var viewModel = SidebarViewModel()
    @State private var selection: VASideBarItem?
    
    var body: some View {
        // container view hat handles the loading stages
        SpinnerWhileLoadingView(viewModel.loadingStatus) {
            // side bar struct, handling side menu and pages
            SideBar(selection: $selection) { showingSidebar in
                // iterate through sidebar items which contains the pages
                ForEach(viewModel.items) { sideBarItem in
                    // init page
                    WPPage(sidebarItem: sideBarItem, showingSidebar: showingSidebar)
                        .sideBarItem(sideBarItem, selection: $selection)
                }
            }
        } errorAlert: { error in
            return Alert(title: Text("Oops"), message: Text(error.localizedDescription))
        }
        .ignoresSafeArea()
        .onAppear{
            // load items on appearance
            viewModel.loadPages()
        }
        .onReceive(viewModel.$items) { items in
            // when reloaded, set selection to first item
            self.selection = items.first
        }
    }
}

struct MainTabBarView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabBarView()
    }
}
