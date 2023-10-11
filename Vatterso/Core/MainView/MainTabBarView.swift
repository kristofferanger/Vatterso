//
//  MainTabBarView.swift
//  Vatterso
//
//  Created by Kristoffer Anger on 2023-06-01.
//

import SwiftUI

struct MainTabBarView: View {

    @StateObject private var viewModel = SidebarViewModel()
    
    var body: some View {
        // container view hat handles the loading stages
        SpinnerWhileLoadingView(viewModel.loadingStatus) {
            // side bar struct, handling side menu and pages
            SidebarView(items: viewModel.items) { selection, showingSidebar in
                // iterate through sidebar items which contains the pages
                
//                Text("Page one")
//                    .sideBarItem(SidebarItem(posts: []), selection: selection)
//                Text("Page two")
//                    .sideBarItem(SidebarItem(posts: []), selection: selection)

//                ForEach(viewModel.items) { item in
//                    WPPageView(selection: item, showingSidebar: showingSidebar)
//                        .sideBarItem(item, selection: selection)
//                }
//
                WPPageView(item: selection.wrappedValue, showingSidebar: showingSidebar)
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
    }
}

struct MainTabBarView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabBarView()
    }
}
