//
//  ZoomableScrollView.swift
//  Vatterso
//
//  Created by Kristoffer Anger on 2023-10-01.
//

import UIKit
import SwiftUI

// Scrollview for SwiftUI with ability to zoom and scroll content
struct ZoomableScrollView<Content: View>: UIViewRepresentable {
    
    private var enableTapToReset: Bool
    private var content: Content
    
    init(enableTapToReset: Bool = false, @ViewBuilder content: () -> Content) {
        self.enableTapToReset = enableTapToReset
        self.content = content()
    }
    
    func makeCoordinator() -> Coordinator  {
        // create a UIHostingController to hold our SwiftUI content
        let hostingViewController = UIHostingController(rootView: self.content)
        return Coordinator(hostingController: hostingViewController)
    }
    
    func makeUIView(context: Context) -> UIScrollView {
        // set up the UIScrollView
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator  // for viewForZooming(in:)
        scrollView.maximumZoomScale = 20
        scrollView.minimumZoomScale = 1
        scrollView.bouncesZoom = true
        scrollView.alwaysBounceVertical = true
        scrollView.backgroundColor = .secondarySystemBackground
        
        // create a UIHostingController to hold our SwiftUI content
        let hostedView = context.coordinator.hostingController.view!
        hostedView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        hostedView.frame = scrollView.bounds
        hostedView.backgroundColor = .clear
        
        // add double tap to reset view
        if enableTapToReset {
            let doubleTapGesture = UITapGestureRecognizer()
            doubleTapGesture.numberOfTapsRequired = 2
            
            hostedView.addGestureRecognizer(doubleTapGesture) { gesture in
                scrollView.setZoomScale(1.0, animated: true)
            }
        }
        // add content view and return scroll view
        scrollView.addSubview(hostedView)
        return scrollView
    }
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {
        // empty
    }
    
    // MARK: - Coordinator
    class Coordinator: NSObject, UIScrollViewDelegate {
        var hostingController: UIHostingController<Content>
        
        init(hostingController: UIHostingController<Content>) {
            self.hostingController = hostingController
        }
        
        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return hostingController.view
            
        }
    }
}
