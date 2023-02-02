//  TaskModelStorage.swift
//  TinyTasks
//
//  Created by Elena Gordienko on 21.01.23.
//  
//

import CoreData
import Foundation
import SwiftUI

final class TaskModelStorage: ObservableObject {
    private weak var viewContext: NSManagedObjectContext?
    
    init(viewContext: NSManagedObjectContext?) {
        self.viewContext = viewContext
    }
    
    private func createTask() -> TaskModel? {
        viewContext.map { TaskModel(context: $0) }
    }
    
    private func delete(_ object: NSManagedObject) {
        viewContext?.delete(object)
    }
    
    func saveContext() {
        do {
            try viewContext?.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    func addTask() {
        // FIXME: add error handling
        guard let newTask = createTask() else { return }
        newTask.text = ""
        newTask.isDone = false
        saveContext()
    }
    
    func deleteTasks(_ tasks: [TaskModel]) {
        tasks.forEach(delete)
        saveContext()
    }
}
