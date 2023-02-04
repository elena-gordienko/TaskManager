//  TaskModelStorage.swift
//  TinyTasks
//
//  Created by Elena Gordienko on 21.01.23.
//  
//

import CoreData
import Foundation
import SwiftUI

protocol OrderedManagedObject: AnyObject {
    var order: Int16 { get set }
}

protocol ModelStorage: ObservableObject {
    func saveContext()
}

protocol TaskStorage: ModelStorage {
    func addTask(for list: TaskListModel)
    func deleteTasks(_ tasks: [TaskModel])
    func moveTasks(_ orderedTasks: [TaskModel], from source: IndexSet, to destination: Int)
    func updateOrder(for tasks: [TaskModel])
}

protocol TaskListStorage: ModelStorage {
    func addTaskList(number: Int)
    func deleteTaskLists(_ taskLists: [TaskListModel])
    func moveTasksList(_ orderedTasks: [TaskListModel], from source: IndexSet, to destination: Int)
    func updateOrder(for taskLists: [TaskListModel])
}

final class TaskModelStorage: ModelStorage {
    private weak var viewContext: NSManagedObjectContext?
    
    init(viewContext: NSManagedObjectContext?) {
        self.viewContext = viewContext
    }
    
    private func delete(_ object: NSManagedObject) {
        viewContext?.delete(object)
    }
    
    private func updateOrder<Object: NSManagedObject & OrderedManagedObject>(_ objects: [Object]) {
        // This is done in reverse order to minimize changes to the indices.
        for reverseIndex in stride(from: objects.count - 1, through: 0, by: -1) {
            objects[reverseIndex].order = Int16(reverseIndex)
        }
    }
    
    private func move<Object: NSManagedObject & OrderedManagedObject>(
        _ objects: [Object],
        from source: IndexSet,
        to destination: Int
    ) {
        var orderedObjects = objects
        orderedObjects.move(fromOffsets: source, toOffset: destination)
        updateOrder(orderedObjects)
        saveContext()
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
}

extension TaskModelStorage: TaskStorage {
    private func createTask() -> TaskModel? {
        viewContext.map { TaskModel(context: $0) }
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
    
    func deleteTasks(_ tasks: [TaskModel]) {
        tasks.forEach(delete)
        saveContext()
    }
    
    func moveTasks(_ orderedTasks: [TaskModel], from source: IndexSet, to destination: Int) {
        move(orderedTasks, from: source, to: destination)
    }
    
    func updateOrder(for tasks: [TaskModel]) {
        updateOrder(tasks)
        saveContext()
    }
}

extension TaskModelStorage: TaskListStorage {
    private func createTaskList() -> TaskListModel? {
        viewContext.map { TaskListModel(context: $0) }
    }
    
    func addTaskList(number: Int) {
        // FIXME: add error handling
        guard let newTask = createTaskList() else { return }
        newTask.title = "New list"
        newTask.lastChanged = Date()
        newTask.order = Int16(number)
        saveContext()
    }
    
    func updateOrder(for taskLists: [TaskListModel]) {
        updateOrder(taskLists)
        saveContext()
    }
    
    
    func deleteTaskLists(_ taskLists: [TaskListModel]) {
        taskLists.forEach(delete)
        saveContext()
    }
    
    func moveTasksList(_ orderedTasks: [TaskListModel], from source: IndexSet, to destination: Int) {
        move(orderedTasks, from: source, to: destination)
    }
}
