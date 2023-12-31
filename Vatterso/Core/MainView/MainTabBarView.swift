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
                // present selected side bar item
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
