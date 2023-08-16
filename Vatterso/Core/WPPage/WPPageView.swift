//
//  WPPageView.swift
//  Vatterso
//
//  Created by Kristoffer Anger on 2023-08-14.
//

import SwiftUI
import SDWebImageSwiftUI

// a page that shows wordpress content
// it can show both a blog with posts and a page
// since it's basically the same data structure
struct WPPageView: View {
    // the page data,
    // 1 item == page, 1+ items == blog
    private var page: SidebarItem
    
    private var posts: [WPPost] {
        switch page.pageType {
        case .blog(let posts):
            return posts
        case .page(let page):
            return [page]
        }
    }
    
    private var title: String {
        return page.pageType.title
    }
    
    private var isBlog: Bool {
        return page.pageType.isBlog
    }
    // make the side bar appear
    @Binding var showingSidebar: Bool
    @Binding var selection: SidebarItem?
    
    init(sidebarItem: SidebarItem, selection: Binding<SidebarItem?>, showingSidebar: Binding<Bool>) {
        self.page = sidebarItem
        self._selection = selection
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
            .onChange(of: selection, perform: { selection in
                // only interested in clicks on a tab with same tabId but different page id
                guard let selection, selection.tabId == page.tabId, selection.id != page.id else { return }
                // update page
                print("update with page: \(selection.name)")
                // self.page = selection
            })
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
