//
//  Start.swift
//  Vatterso
//
//  Created by Kristoffer Anger on 2023-06-04.
//

import SwiftUI

struct Start: View {
    
    @StateObject var viewModel = StartPageViewModel()
        
    var body: some View {
        NavigationView {
            ScrollView {
                switch viewModel.pages {
                case .finished(let pages):
                    switch pages {
                    case .failure(let error):
                        Text("Something went wrong: \(error.localizedDescription)")
                    case .success(let pages):
                        LazyVStack {
                            ForEach(pages) { page in
                                Text(page.title.text)
                            }
                        }
                    }
                case .loading:
                    ProgressView()
                }
            }
            .navigationTitle("Test")
        }
        .onAppear {
            viewModel.loadPages()
        }
    }
    
    struct SideBarContent: View {
        var body: some View {
            Text("Test")
        }
    }
    
    struct ScrolledContent: View {
        
        let items = [String](repeating: "Hep", count: 100)
        
        var body: some View {
            VStack {
                ForEach(items, id: \.self) { letter in
                    Text(letter)
                }
            }
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
                LinearGradient(gradient: Gradient(colors: [.black.opacity(0.2), .black.opacity(0.6)]), startPoint: .top, endPoint: .bottom)
            }
        )
    }
}

struct ItemRow: View {
    let category: Bool
    let text: String
    
    init(_ text: String, isCategory: Bool = false) {
        self.category = isCategory
        self.text = text
    }
    
    var body: some View {
        HStack {
            Circle().stroke() // this can be custom control
                .frame(width: 20, height: 20)
                .onTapGesture {
                    // handle tap here
                }
            if category {
                Text(self.text).bold()
            } else {
                Text(self.text)
            }
        }
    }
}

struct TestNestedLists: View {
    var body: some View {
        List { // next pattern easily wrapped with ForEach
            ItemRow("Category", isCategory: true) // this can be section's header
            Section {
                ItemRow("Item 1")
                ItemRow("Item 2")
                ItemRow("Item 3")
            }.padding(.leading, 20)
        }
    }
}

struct Start_Previews: PreviewProvider {
    static var previews: some View {
        Start()
    }
}
