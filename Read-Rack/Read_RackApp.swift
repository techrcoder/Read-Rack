//
//  Read_RackApp.swift
//  Read-Rack
//
//  Created by Rohan Patel on 4/21/25.
//

import SwiftUI

@main
struct Read_RackApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
