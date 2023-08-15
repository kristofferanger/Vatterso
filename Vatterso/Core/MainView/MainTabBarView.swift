//
//  MainTabBarView.swift
//  Vatterso
//
//  Created by Kristoffer Anger on 2023-06-01.
//

import SwiftUI

struct MainTabBarView: View {

    @StateObject private var viewModel = SidebarViewModel()
    @State private var selection: SidebarItem?
    
    var body: some View {
        // container view hat handles the loading stages
        SpinnerWhileLoadingView(viewModel.loadingStatus) {
            // side bar struct, handling side menu and pages
            SidebarView(selection: $selection) { showingSidebar in
                // iterate through sidebar items which contains the pages
                ForEach(viewModel.items) { sideBarItem in
                    // init page
                    WPPageView(sidebarItem: sideBarItem, showingSidebar: showingSidebar)
                        .sideBarItem(sideBarItem, selection: $selection)
                }
            }
        } errorAlert: { error in
            let alert = Alert(title: Text("Oops"), message: Text(error.localizedDescription), dismissButton: .default(Text("Retry")) {
                // try load items again on error dismiss
                viewModel.reloadPages()
            })
           
            return alert
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
