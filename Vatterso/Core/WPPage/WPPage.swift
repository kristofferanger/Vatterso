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
                Text(page.excerpt.text)
                Text(page.content.text)
            }
            .padding()
        }
        .navigationTitle(page.title.text)
    }
}
