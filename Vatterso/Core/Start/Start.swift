//
//  Start.swift
//  Vatterso
//
//  Created by Kristoffer Anger on 2023-06-04.
//

import SwiftUI

//
enum LoadingData<T> {
    case loading
    case finished(Result<T, NetworkingError>)
    
    init() {
        self = .loading
    }
}

struct SpinnerWhileLoadingView<Data, Content>: View where Content: View {
    
    private var loadingData: LoadingData<Data>
    private var errorAlert: (NetworkingError) -> Alert
    @ViewBuilder private var content: (Data) -> Content
    
    @State private var error: NetworkingError?
    
    init(_ data: LoadingData<Data>, @ViewBuilder content: @escaping (Data) -> Content, errorAlert: @escaping (NetworkingError) -> Alert) {
        self.loadingData = data
        self.content = content
        self.errorAlert = errorAlert
    }
    
    var body: some View {
        Group {
            switch loadingData {
            case .finished(let loadingResult):
                switch loadingResult {
                case .success(let data):
                    content(data)
                case .failure(let error):
                    Color.clear
                        .onAppear {
                            self.error = error
                        }
                }
            case .loading:
                ProgressView()
            }
        }
        .alert(item: $error) { error in
            return errorAlert(error)
        }
    }
}


struct Start: View {
    
    @StateObject var viewModel = StartPageViewModel()
        
    var body: some View {
        NavigationView {
            SpinnerWhileLoadingView(viewModel.pages) { pages in
                ScrollView {
                    LazyVStack {
                        ForEach(pages) { page in
                            Text(page.title.text)
                        }
                    }
                }
            } errorAlert: { error in
                Alert(title: Text("Something went wrong"), message: Text(error.localizedDescription))
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
