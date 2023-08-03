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
            VStack(alignment: .leading, spacing: 8) {
                ForEach(page.content.paragraphs) { paragraph in
                    if let text = paragraph.text {
                        Text(.init(text))
                            .font(paragraph.font ?? Font.body)
                            .foregroundColor(paragraph.color ?? Color.primary)
                    }
                    if let imageUrl = paragraph.imageUrl {
                        // wite out image for now
                        Text(imageUrl)
                    }
                }
            }
            .padding()
        }
        .navigationTitle(page.title.text)
    }
}
