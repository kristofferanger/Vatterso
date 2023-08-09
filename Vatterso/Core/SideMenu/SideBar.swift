//
//  SideBar.swift
//  Vatterso
//
//  Created by Kristoffer Anger on 2023-08-08.
//

import SwiftUI

struct SideBar<Content>: View where Content: View {

    @Binding var selection: VASideBarItem?
    private var content: () -> Content
    
    @State private var items: [VASideBarItem] = []
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                content()
            }
        }
        .onPreferenceChange(SidebarItemPreferenceKey.self) { value in
            self.items = value
        }
    }
    
    /// Creates an instance that selects from content associated with
    /// `Selection` values.
    init(selection: Binding<VASideBarItem?>, @ViewBuilder content: @escaping () -> Content) {
        self._selection = selection
        self.content = content
    }
}

//struct SideBar_Previews: PreviewProvider {
//    static var previews: some View {
//        SideBar()
//    }
//}
