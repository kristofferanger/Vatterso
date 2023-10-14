//
//  WPImage.swift
//  Vatterso
//
//  Created by Kristoffer Anger on 2023-10-01.
//

import SwiftUI

struct WPImage: View {
    
    private var url: URL?
    
    init(url: URL?) {
        self.url = url
    }
    
    var body: some View {
        AsyncImage(url: self.url) { phase in
            if let image = phase.image {
                image
                    .resizable()
                    .scaledToFit()
            }
            else {
                ProgressView()
            }
        }
    }
}
