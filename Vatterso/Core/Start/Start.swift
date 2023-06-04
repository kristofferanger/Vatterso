//
//  Start.swift
//  Vatterso
//
//  Created by Kristoffer Anger on 2023-06-04.
//

import SwiftUI

struct Start: View {
    var body: some View {
        VStack(spacing: 0){
            header
            Spacer()
            
        }
    }
    
    // header
    var header: some View {
        ZStack() {
            VStack {
                Spacer()
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading) {
                        Text("Vättersö")
                            .font(.largeTitle)
                            .fontWeight(.semibold)
                        Text("i Stockholms norra skärgård")
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("Position:")
                        Text("N 59.5681, O 18.7028")
                    }
                }
                .font(.caption)
                .foregroundColor(.white)
            }
            .padding(6)
        }
        .frame(height: 120)
        .background(
            ZStack {
                Image("top_image1")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity)
                LinearGradient(gradient: Gradient(colors: [.clear, .black.opacity(0.8)]), startPoint: .top, endPoint: .bottom)
            }
        )
    }
}

struct Start_Previews: PreviewProvider {
    static var previews: some View {
        Start()
    }
}
