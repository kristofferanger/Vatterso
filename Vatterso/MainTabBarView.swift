//
//  MainTabBarView.swift
//  Vatterso
//
//  Created by Kristoffer Anger on 2023-06-01.
//

import SwiftUI

struct MainTabBarView: View {

    @State var selection: VATabBarItem = VATabBarItem(title: "Home", iconName: "house")
    
    var body: some View {
        VATabBarContainerView(selection: $selection) {
            Start()
                .tabBarItem(VATabBarItem(title: "Home", iconName: "house"), selection: $selection)
            Color.blue
                .tabBarItem(VATabBarItem(title: "Favourites", iconName: "heart"), selection: $selection)
            Color.orange
                .tabBarItem(VATabBarItem(title: "Profile", iconName: "person"), selection: $selection)
        }
        .ignoresSafeArea()
    }
}

struct MainTabBarView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabBarView()
    }
}
