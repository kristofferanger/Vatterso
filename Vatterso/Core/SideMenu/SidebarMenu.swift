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
        ZStack(alignment: .bottom) {
            if (isShowing) {
                Color.black
                    .opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        isShowing.toggle()
                    }
                content()
                    .transition( .move(edge: .leading))
                    .background(
                        Color.clear
                    )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .ignoresSafeArea()
        .animation(.easeInOut, value: isShowing)
    }
}

struct SideMenuView: View {
    
    var tabs: [VASideBarItem]
    @Binding var selectedSideMenuTab: String
    @Binding var presentSideMenu: Bool
    
    var body: some View {
        HStack {
            ZStack{
                Rectangle()
                    .fill(.white)
                    .frame(width: 270)
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 3)
                
                VStack(alignment: .leading, spacing: 0) {
                    Spacer(minLength: 40)
                    List(tabs, children: \.items) { row in
                        
                        Button {
                            selectedSideMenuTab = row.name
                        } label: {
                            HStack {
                                if let icon = row.icon {
                                    Image(systemName: icon)
                                }
                                Text(row.name)
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
        .background(.clear)
    }
    
}


//struct SidebarMenu_Previews: PreviewProvider {
//    static var previews: some View {
//        SidebarMenu()
//    }
//}
