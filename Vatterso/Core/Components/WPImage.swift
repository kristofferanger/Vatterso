//
//  WPImage.swift
//  Vatterso
//
//  Created by Kristoffer Anger on 2023-10-01.
//

import SwiftUI

struct WPImage: View {
    
    private let url: URL?
    private let imageLoaded: () -> Void
        
    init(url: URL?, imageLoaded: @escaping (() -> Void) = {}) {
        self.url = url
        self.imageLoaded = imageLoaded
    }
    
    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                ZStack {
                    background()
                    ProgressView()
                }
            case .success(let image):
                image
                    .resizable()
                    .scaledToFit()
                    .onAppear {
                        imageLoaded()
                    }
            default:
                ZStack {
                    background()
                    placeholderImage()
                }
            }
        }
    }
    
    private func background() -> some View {
        Color(white: 0.95)
            .frame(height: 260)
    }
    
    private func placeholderImage() -> some View {
        Image(systemName: "photo")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(maxWidth: 80, alignment: .center)
            .foregroundColor(Color(white: 0.85))
    }
}

/// A NavigationLink that encapsules a WPImage
/// where you go to zoomable and scrollable
/// copy of that image when clicked
struct ClickableImage: View {
    
    let url: URL
    @State var enabled = false
    
    var body: some View {
                
        NavigationLink {
            // detail view image
            ZoomableScrollView(enableTapToReset: true) {
                WPImage(url: url)
            }
            .navigationBarTitleDisplayMode(.inline)
        } label: {
            // the image
            WPImage(url: url) {
                enabled = true
            }
            .padding(.vertical, 10)
            .frame(maxWidth: 400)
        }
        .disabled(!enabled)
    }
}
