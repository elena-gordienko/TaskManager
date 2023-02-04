//
//  TinyTasksApp.swift
//  TinyTasks
//
//  Created by Elena Gordienko on 21.01.23.
//

import SwiftUI

@main
struct TinyTasksApp: App {
    let persistenceController: PersistenceController
    let taskModelStorage: TaskModelStorage
    
    init() {
        persistenceController = PersistenceController.shared
        taskModelStorage = TaskModelStorage(viewContext: persistenceController.container.viewContext)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(
                    \.managedObjectContext,
                     persistenceController.container.viewContext
                )
                .environmentObject(taskModelStorage)
        }.commands {
            SidebarCommands()
        }
    }
}
