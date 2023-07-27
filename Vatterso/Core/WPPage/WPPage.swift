//
//  WPPage.swift
//  Vatterso
//
//  Created by Kristoffer Anger on 2023-07-25.
//

import SwiftUI

struct WPPage: View {
    
    var page: Page
    
    var body: some View {
        ScrollView {
            VStack {
                Text(page.excerpt.rendered)
                Text(page.content.rendered)
            }
            .padding()
        }
        .navigationTitle(page.title.text)
    }
}
