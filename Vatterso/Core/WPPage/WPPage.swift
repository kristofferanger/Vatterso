//
//  WPPage.swift
//  Vatterso
//
//  Created by Kristoffer Anger on 2023-07-25.
//

import SwiftUI
import SDWebImageSwiftUI

// a page that shows wordpress content
// it can show both a blog with posts and a page
// since it's basically the same data structure
struct WPPage: View {
    // the page data,
    // 1 item == page, 1+ items == blog
    private var posts: [WPPost]
    private var title: String
    private var isBlog: Bool {
        return posts.count > 1
    }
    // make the side bar appear
    @Binding var showingSidebar: Bool

    init(sidebarItem: SidebarItem, showingSidebar: Binding<Bool>) {
        switch sidebarItem.pageType {
        case .blog(let posts):
            self.posts = posts
        case .page(let page):
            self.posts = [page]
        }
        self.title = sidebarItem.pageType.title
        self._showingSidebar = showingSidebar
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 40) {
                    ForEach(posts) { post in
                        postView(post: post)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .navigationTitle(title)
            .navigationBarItems(leading: Button(action: {
                // hamburger button pressed
                showingSidebar.toggle()
            }, label: {
                Image(systemName: "line.3.horizontal")
            }))
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    // private stuff
    private func postView(post: WPPost) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            if isBlog {
                Text(post.title.text)
                    .font(.headline)
            }
            ForEach(post.content.paragraphs) { paragraph in
                paragraphView(paragraph: paragraph)
            }
            if isBlog {
                Text("Publicerat den \(post.date.dateSting()) av \(post.authorName)")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private func paragraphView(paragraph: WPParagraph) -> some View {
        // paragraph is either a text or an image
        Group {
            if let text = paragraph.text {
                // text paragraph
                Text(.init(text))
                    .font(paragraph.font)
                    .foregroundColor(paragraph.color ?? Color.primary)
            }
            if let imageUrl = paragraph.imageUrl {
                // image paragraph
                NavigationLink {
                    // clicked image
                    ScrollView {
                        imageView(url: imageUrl)
                            .scaledToFill()
                    }
                } label: {
                    imageView(url: imageUrl)
                        .scaledToFit()
                        .padding(.vertical, 10)
                        .frame(maxWidth: 400)
                }
            }
        }
    }

    private func imageView(url: URL) -> some View {
        return WebImage(url: url)
            .resizable()
    }
}
