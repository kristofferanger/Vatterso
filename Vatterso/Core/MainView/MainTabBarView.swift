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
            SidebarView2(viewModel: viewModel) { selection, showingSidebar in
                // iterate through sidebar items which contains the pages
                WPPageView(sidebarItem: selection, showingSidebar: showingSidebar)
                    //.sideBarItem(viewModel.items.first!, selection: $selection)
                
                
//                ForEach(viewModel.items) { sideBarItem in
//                    // init a page for each sidebar item
//                    WPPageView(sidebarItem: sideBarItem, selection: $selection, showingSidebar: showingSidebar)
//                        .sideBarItem(sideBarItem, selection: $selection)
//                }
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
