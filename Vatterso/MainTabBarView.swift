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
        SideBar(selection: $selection) {
            SpinnerWhileLoadingView(viewModel.loadingStatus) {
                ForEach(viewModel.items) { sideBarItem in
                    switch sideBarItem.pageType {
                    case .blog(let posts):
                        WPPage(posts: posts)
                            .sideBarItem(sideBarItem, selection: $selection)
                    case .page(let page):
                        WPPage(page: page)
                            .sideBarItem(sideBarItem, selection: $selection)
                    }
                }
            } errorAlert: { error in
                return Alert(title: Text(""), message: Text(error.localizedDescription))
            }
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
