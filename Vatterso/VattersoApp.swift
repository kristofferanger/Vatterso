//
//  VattersoApp.swift
//  Vatterso
//
//  Created by Kristoffer Anger on 2023-06-01.
//

import SwiftUI

@main
struct VattersoApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            MainTabBarView()
//            ContentView()
//                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
