//
//  SpinnerWhileLoadingView.swift
//  Vatterso
//
//  Created by Kristoffer Anger on 2023-08-10.
//

import SwiftUI

struct SpinnerWhileLoadingView<Content>: View where Content: View {
    
    private var status: LoadingStatus
    private var errorAlert: (NetworkingError) -> Alert
    @ViewBuilder private var content: () -> Content
    
    @State private var error: NetworkingError?
    
    init(_ status: LoadingStatus, @ViewBuilder content: @escaping () -> Content, errorAlert: @escaping (NetworkingError) -> Alert) {
        self.status = status
        self.content = content
        self.errorAlert = errorAlert
    }
    
    var body: some View {
        ZStack {
            switch status {
            case .error(let error):
                Color.clear
                    .onAppear {
                        self.error = error
                    }
            case .loading:
                ProgressView()
            case .finished:
                content()
            case .unknown:
                Color.clear
            }
        }
        .alert(item: $error) { error in
            return errorAlert(error)
        }
    }
}

struct SpinnerWhileLoadingView_Previews: PreviewProvider {
    
    static var previews: some View {
        SpinnerWhileLoadingView(LoadingStatus.loading) {
            Text("Content is showing")
        } errorAlert: { error in
            Alert(title: Text("Something went wrong"), message: Text (error.localizedDescription))
        }

    }
}
