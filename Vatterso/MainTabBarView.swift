//
//  MainTabBarView.swift
//  Vatterso
//
//  Created by Kristoffer Anger on 2023-06-01.
//

import SwiftUI

struct MainTabBarView: View {

    @StateObject private var viewModel = SidebarViewModel()
    @State private var selection: VATabBarItem?
    
    
    var body: some View {
        VATabBarContainerView(selection: $selection) {
            ForEach(viewModel.items) { sideBarItem in
                switch sideBarItem.pageType {
                case .blog(let posts):
                    WPPage(page: posts.first!)
                        .tabBarItem(VATabBarItem(title: sideBarItem.name, iconName: sideBarItem.icon), selection: $selection)
                case .page(let page):
                    WPPage(page: page)
                        .tabBarItem(VATabBarItem(title: sideBarItem.name, iconName: sideBarItem.icon), selection: $selection)
                }
            }
        }
        .ignoresSafeArea()
        .onAppear{ viewModel.loadPages() }
    }
}

struct MainTabBarView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabBarView()
    }
}
