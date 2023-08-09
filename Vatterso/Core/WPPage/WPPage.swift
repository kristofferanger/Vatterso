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
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(posts) { post in
                        VStack(alignment: .leading, spacing: 8) {
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
                            if posts.count > 1 {
                                Text("Publicerat av \(post.author)")
                                    .font(.footnote)
                                    .foregroundColor(Color.secondary)
                            }
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .navigationTitle(navigationTitle)
            .navigationBarItems(leading: Button(action: {
                print("hep")
            }, label: {
                Image(systemName: "line.3.horizontal")
            }))
        }
    }
}
