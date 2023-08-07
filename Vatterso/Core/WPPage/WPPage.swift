//
//  WPPage.swift
//  Vatterso
//
//  Created by Kristoffer Anger on 2023-07-25.
//

import SwiftUI
import SDWebImageSwiftUI

struct WPPage: View {
    
    var page: WPPost

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(page.content.paragraphs) { paragraph in
                    if let text = paragraph.text {
                        Text(.init(text))
                            .font(paragraph.font)
                            .foregroundColor(paragraph.color ?? Color.primary)
                    }
                    if let imageUrl = paragraph.imageUrl {
                        WebImage(url: imageUrl)
                            .resizable()
                            .scaledToFit()
                            .padding(.vertical, 16)
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle(page.title.text)
    }
}
