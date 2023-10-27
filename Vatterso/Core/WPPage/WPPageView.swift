//
//  WPPageView.swift
//  Vatterso
//
//  Created by Kristoffer Anger on 2023-08-14.
//

import SwiftUI

// a page that shows wordpress content
// it can show both a blog with posts and a page
// since it's basically the same data structure
struct WPPageView: View {
    // the page data,
    // 1 item == page, 1+ items == blog
    private var item: SidebarItem?
    
    // make the side bar appear
    @Binding var showingSidebar: Bool
    
    init(item: SidebarItem?, showingSidebar: Binding<Bool>? = nil) {
        self.item = item
        self._showingSidebar = showingSidebar ?? .constant(false)
    }
    
    // start page for tabs with navigation bar
    // showing title and navbar button
    var body: some View {
        NavigationView {
            VStack {
                if let page = item {
                    WPPageContentView(page: page)
                }
                else {
                    ProgressView()
                }
            }
            .navigationBarItems(leading: Button(action: {
                // hamburger button pressed
                showingSidebar.toggle()
            }, label: {
                Image(systemName: "line.3.horizontal")
            }))
        }
        .navigationViewStyle(.stack)
    }
}

// the view that show the actual content of the page
struct WPPageContentView: View {
    
    var page: SidebarItem
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 40) {
                ForEach(page.posts) { post in
                    postView(post: post)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle(page.title)
    }
    
    private var isBlog: Bool {
        return page.pageType == .blog
    }
    
    private func publishedString(post: WPPost) -> String {
        var published = "Publicerat den \(post.date.dateSting())"
        if let authorName = post.authorName {
            published += " av \(authorName)"
        }
        return published
    }
    
    // view for showing a post (in a page)
    private func postView(post: WPPost) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            // set headline for blog page
            if isBlog {
                Text(post.title.text)
                    .font(.headline)
            }
            // set paragraphs
            ForEach(post.content.paragraphs) { paragraph in
                paragraphView(paragraph: paragraph)
            }
            // set footer for blog page
            if isBlog {
                Text(publishedString(post: post))
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // view that shows a paragraph
    private func paragraphView(paragraph: WPParagraph) -> some View {
        // paragraph is either a text, list, grid or an image
        ZStack {
            if let text = markdownText(paragraph: paragraph)   {
                // text paragraph
                Text(text)
                    .font(paragraph.font)
                    .foregroundColor(paragraph.color ?? Color.primary)
            }
            else if let text = paragraph.listText {
                // list paragraph
                HStack(alignment: .top) {
                    Text("•")
                    Text(text)
                        .font(paragraph.font)
                        .foregroundColor(paragraph.color ?? Color.primary)
                }
            }
            else if let table = paragraph.table, let grid = table.rows {
                // grid paragraph
                gridView(grid: grid)
            }
            else if let imageUrl = paragraph.imageUrl {
                // image paragraph
                imageView(url: imageUrl)
            }
        }
    }
    
    private func markdownText(paragraph: WPParagraph) -> LocalizedStringKey? {
        guard let string = paragraph.text else { return nil }
        return LocalizedStringKey(string)
    }
    
    private func listText(paragraph: WPParagraph) -> String? {
        if let text = paragraph.text, text.hasPrefix("\u{2022}") {
            return text
        }
        return nil
    }
    
    private func gridView(grid: [[String]]) -> some View {
        Grid(alignment: .leading, horizontalSpacing: 8, verticalSpacing: 12) {
            ForEach(grid, id: \.self) { row in
                GridRow(alignment: .top) {
                    ForEach(row, id: \.self) { text in
                        Text(text)
                            .font( .caption)
                    }
                }
            }
        }
    }
    
    private func imageView(url: URL) -> some View {
        NavigationLink {
            // detail view image
            ZoomableScrollView(enableTapToReset: true) {
                WPImage(url: url)
            }
            .navigationBarTitleDisplayMode(.inline)
        } label: {
            // the image
            WPImage(url: url)
                .padding(.vertical, 10)
                .frame(maxWidth: 400)
        }
    }
}


