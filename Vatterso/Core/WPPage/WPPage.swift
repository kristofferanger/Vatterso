//
//  WPPage.swift
//  Vatterso
//
//  Created by Kristoffer Anger on 2023-07-25.
//

import SwiftUI
import SDWebImageSwiftUI

struct WPPage: View {
    
    private var posts: [WPPost]
    
    init(page: WPPost) {
        self.posts = [page]
    }
    
    init(posts: [WPPost]) {
        self.posts = posts
    }
    
    private var navigationTitle: String {
        let firstPostTitle = self.posts.first?.title.text
        return firstPostTitle ?? ""
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(posts) { post in
                    ForEach(post.content.paragraphs) { paragraph in
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
                    // check if the page is showing multiple posts
                    if posts.count > 1 {
                        Text("publicerat av \(post.author)")
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle(navigationTitle)
    }
}
