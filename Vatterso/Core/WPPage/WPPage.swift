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
// since it's basicly the same data structure

struct WPPage: View {
    // the page data,
    // 1 item == page, 1+ items == blog
    private var posts: [WPPost]
    // make the side bar appear
    @Binding var showingSidebar: Bool

    init(sidebarItem: VASideBarItem, showingSidebar: Binding<Bool>) {
        switch sidebarItem.pageType {
        case .blog(let posts):
            self.posts = posts
        case .page(let page):
            self.posts = [page]
        }
        self._showingSidebar = showingSidebar
    }
    
    internal var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(posts) { post in
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(post.content.paragraphs) { paragraph in
                                paragraphView(paragraph: paragraph)
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
                // hamburger button pressed
                showingSidebar.toggle()
            }, label: {
                Image(systemName: "line.3.horizontal")
            }))
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private var navigationTitle: String {
        let firstPostTitle = self.posts.first?.title.text
        return firstPostTitle ?? ""
    }
    
    private func paragraphView(paragraph: WPParagraph) -> some View {
        Group {
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
}
