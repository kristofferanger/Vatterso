//
//  VATabBarContainerView.swift
//  Vatterso
//
//  Created by Kristoffer Anger on 2023-06-01.
//

import SwiftUI


struct VATabBarContainerView<Content: View>: View {
    
    @Binding var selection: VATabBarItem
    private var content: () -> Content
    
    @State private var tabs: [VATabBarItem] = []
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                content()
            }
            VATabBarView(tabs: tabs, selection: $selection)
        }
        .onPreferenceChange(TabBarItemsPreferenceKey.self) { value in
            self.tabs = value
            
        }
    }
    
    /// Creates an instance that selects from content associated with
    /// `Selection` values.
    init(selection: Binding<VATabBarItem>, @ViewBuilder content: @escaping () -> Content) {
        self._selection = selection
        self.content = content
    }

}

//struct VATabBarContainerView_Previews: PreviewProvider {
//    
//    static let tabs = [VATabBarItem(title: "Home", iconName: "house"),
//                       VATabBarItem(title: "Favorites", iconName: "heart"),
//                       VATabBarItem(title: "Profile", iconName: "person")]
//
//    @State var selected = tabs.first!
//
//    static var previews: some View {
//        VATabBarContainerView(tabs: tabs, selection: $selected) {
//            Text("Hello")
//        }
//    }
//}
