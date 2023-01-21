//
//  TinyTasksApp.swift
//  TinyTasks
//
//  Created by Elena Gordienko on 21.01.23.
//

import SwiftUI

@main
struct TinyTasksApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
