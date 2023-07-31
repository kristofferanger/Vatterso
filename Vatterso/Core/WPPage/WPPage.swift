//
//  WPPage.swift
//  Vatterso
//
//  Created by Kristoffer Anger on 2023-07-25.
//

import SwiftUI

struct WPPage: View {
    
    var page: WPPost

    var body: some View {
        ScrollView {
            VStack {
                Text(.init(page.content.text))
            }
            .padding()
        }
        .navigationTitle(page.title.text)
    }
}
