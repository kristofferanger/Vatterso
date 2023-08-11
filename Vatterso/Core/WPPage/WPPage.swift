//
//  WPPage.swift
//  Vatterso
//
//  Created by Kristoffer Anger on 2023-07-25.
//

import SwiftUI
import SDWebImageSwiftUI

// a page that is showing wordpress contents
// can show both a list of posts and a page
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

    init(sidebarItem: VASideBarItem, showingSidebar: Binding<Bool>) {
        switch sidebarItem.pageType {
        case .blog(let posts):
            self.posts = posts
        case .page(let page):
            self.posts = [page]
        }
        self.title = sidebarItem.pageType.title
        self._showingSidebar = showingSidebar
    }
    
    internal var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 40) {
                    ForEach(posts) { post in
                        VStack(alignment: .leading, spacing: 8) {
                            if isBlog {
                                titleView(text: post.title.text)
                            }
                            ForEach(post.content.paragraphs) { paragraph in
                                paragraphView(paragraph: paragraph)
                            }
                            if isBlog {
                                footnoteView(text: "Publicerat den \(post.date.dateSting()) av \(post.authorName)")
                            }
                        }
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
    
    private func paragraphView(paragraph: WPParagraph) -> some View {
        Group {
            if let text = paragraph.text {
                // text paragraph
                Text(.init(text))
                    .font(paragraph.font)
                    .foregroundColor(paragraph.color ?? Color.primary)
            }
            if let imageUrl = paragraph.imageUrl {
                NavigationLink {
                    // clicked image
                    ScrollView {
                        imageView(url: imageUrl)
                            .scaledToFill()
                        Spacer()
                    }
                } label: {
                    // image paragraph
                    imageView(url: imageUrl)
                        .scaledToFit()
                        .padding(.vertical, 10)
                        .frame(maxWidth: 400)
                }
            }
        }
    }
    
    private func titleView(text title: String) -> some View {
        Text(title)
            .font(.headline)
    }
    
    private func footnoteView(text footnote: String) -> some View {
        Text(footnote)
            .font(.footnote)
            .foregroundColor(Color.secondary)
    }
    
    private func imageView(url: URL) -> some View {
        return WebImage(url: url)
            .resizable()
    }
}
