//
//  manounou_appApp.swift
//  manounou-app
//
//  Created by Vamé TOURÉ on 14/08/2025.
//

import SwiftUI

@main
struct manounou_appApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
