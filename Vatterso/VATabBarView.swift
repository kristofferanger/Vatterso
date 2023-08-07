//
//  VATabBarView.swift
//  Vatterso
//
//  Created by Kristoffer Anger on 2023-06-01.
//

import SwiftUI

struct VATabBarView: View {

    var tabs = [VATabBarItem]()
    @Binding var selection: VATabBarItem? 
    @Namespace private var namespace
    
    var body: some View {
        HStack {
            ForEach(tabs) { item in
                tabView(item: item)
                    .onTapGesture() {
                        selection = item
                    }
            }
        }
        .padding()
        .background( .thinMaterial.opacity(0.5))
        .onChange(of: selection, perform: { value in
            withAnimation(.easeInOut) {
                selection = value
            }
        })
        
    }
    
    private func tabView(item: VATabBarItem) -> some View {
        VStack {
            if let iconName = item.iconName {
                Image(systemName: iconName)
                    .font( .subheadline)
            }
            Text(item.title)
                .font( .system(size: 10, weight: .semibold, design: .rounded))
        }
        .foregroundColor( selection == item ? .accentColor : .gray)
        .padding(6)
        .frame(maxWidth: .infinity)
        .background(
            ZStack {
                if selection == item {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.accentColor.opacity(0.2))
                        .matchedGeometryEffect(id: "BackgroundRectangle", in: namespace)
                }
            }
        )
    }
}

struct VATabBarItem: Identifiable, Hashable {
    
    let title: String
    let iconName: String?
    let iconUrl: String? = nil
    
    var id: String {
        return title
    }
    
}

struct VATabBarView_Previews: PreviewProvider {
    
    static let tabs = [VATabBarItem(title: "Home", iconName: "house"),
                       VATabBarItem(title: "Favorites", iconName: "heart"),
                       VATabBarItem(title: "Profile", iconName: "person")]
    
    static var previews: some View {
        VStack {
            Spacer()
            VATabBarView(tabs: tabs, selection: Binding.constant(tabs.first!))
        }
    }
}
