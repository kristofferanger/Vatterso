//
//  SidebarMenu.swift
//  Vatterso
//
//  Created by Kristoffer Anger on 2023-08-08.
//

import SwiftUI

struct SidebarMenu<Content: View>: View {
    
    @Binding var isShowing: Bool
    @ViewBuilder let content: (() -> Content)
        
    var body: some View {
        ZStack(alignment: .leading) {
            if (isShowing) {
                Color.black
                    .opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        isShowing.toggle()
                    }
                content()
                    .transition( .move(edge: .leading))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .ignoresSafeArea()
        .animation(.easeInOut, value: isShowing)
    }
}

struct SideMenuView: View {
    
    @Binding var tabs: [VASideBarItem]
    @Binding var selectedTab: VASideBarItem?
    @Binding var showingSideMenu: Bool
    
    var body: some View {
        ZStack{
            Rectangle()
                .fill(.white)
                .frame(width: 270)
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 3)
            
            VStack(alignment: .leading, spacing: 0) {
                List(tabs, children: \.items) { tab in
                    Button {
                        selectedTab = tab
                        showingSideMenu = false
                    } label: {
                        HStack {
                            if let icon = tab.icon {
                                Image(systemName: icon)
                            }
                            Text(tab.name)
                        }
                    }
                }
                .listStyle(.plain)
                Spacer()
            }
            .padding(.top, 100)
            .frame(width: 270)
            .background(
                Color.white
            )
        }
        Spacer()
    }
    
}


//struct SidebarMenu_Previews: PreviewProvider {
//    static var previews: some View {
//        SidebarMenu()
//    }
//}
