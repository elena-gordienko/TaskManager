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
    
    private func createTaskList() -> TaskListModel? {
        viewContext.map { TaskListModel(context: $0) }
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
    
    func addTask(for list: TaskListModel) {
        // FIXME: add error handling
        guard let newTask = createTask() else { return }
        newTask.text = ""
        newTask.isDone = false
        newTask.list = list
        newTask.order = list.children.map { Int16($0.count) } ?? 0
        saveContext()
    }
    
    func addTaskList(number: Int) {
        // FIXME: add error handling
        guard let newTask = createTaskList() else { return }
        newTask.title = "New list"
        newTask.lastChanged = Date()
        newTask.order = Int16(number)
        saveContext()
    }
    
    func deleteTasks(_ tasks: [TaskModel]) {
        tasks.forEach(delete)
        // update task order
        saveContext()
    }
    
    func deleteTaskLists(_ taskLists: [TaskListModel]) {
        taskLists.forEach(delete)
        // update task list order
        saveContext()
    }
    
    func moveTasks(_ orderedTasks: [TaskModel], from source: IndexSet, to destination: Int) {
        var tasks = orderedTasks
        tasks.move(fromOffsets: source, toOffset: destination)

        // This is done in reverse order to minimize changes to the indices.
        for reverseIndex in stride(from: tasks.count - 1, through: 0, by: -1) {
            tasks[reverseIndex].order = Int16(reverseIndex)
        }
        saveContext()
    }
    
    func moveTasksList(_ orderedTasks: [TaskListModel], from source: IndexSet, to destination: Int) {
        var tasks = orderedTasks
        tasks.move(fromOffsets: source, toOffset: destination)

        // This is done in reverse order to minimize changes to the indices.
        for reverseIndex in stride(from: tasks.count - 1, through: 0, by: -1) {
            tasks[reverseIndex].order = Int16(reverseIndex)
        }
        saveContext()
    }
}
