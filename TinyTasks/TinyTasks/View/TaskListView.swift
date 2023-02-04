//  TaskListView.swift
//  TinyTasks
//
//  Created by Elena Gordienko on 21.01.23.
//  
//

import Foundation
import SwiftUI

struct TaskListView: View {
    @EnvironmentObject var taskModelStorage: TaskModelStorage
    
    @StateObject var viewModel: ViewModel
    
    @State var tasksList: TaskListModel
    
    @FetchRequest var tasks: FetchedResults<TaskModel>
    
    var storage: any TaskStorage { taskModelStorage }
    
    init(_ receivedTaskList: TaskListModel) {
        _tasksList = .init(initialValue: receivedTaskList)
        _viewModel = .init(
            wrappedValue: .init(
                title: receivedTaskList.wrappedTitle,
                lastChanged: receivedTaskList.lastChanged ?? Date()
            )
        )
        _tasks = FetchRequest(
            entity: TaskModel.entity(),
            sortDescriptors: [NSSortDescriptor(key: "order", ascending: true)],
            predicate: NSPredicate(format: "list == %@", receivedTaskList)
        )
    }
    
    var body: some View {
        List {
            Section {
                TextField("Task List Name", text: $viewModel.title, axis: .vertical)
                    .onReceive(viewModel.$title.debounce(for: 0.5, scheduler: RunLoop.main)) { title in
                        tasksList.title = title
                        tasksList.lastChanged = Date()
                        storage.saveContext()
                    }
                    .font(.largeTitle)
            }
            Section {
                ForEach(tasks) { task in
                    TaskView(task)
                }
                .onMove(perform: moveTasks)
                .onDelete(perform: deleteTasks)
            }
        }
        .toolbar {
#if os(iOS)
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
#endif
            ToolbarItem {
                Button(action: addTask) {
                    Label("Add Task", systemImage: "plus")
                }
            }
        }
    }
                         
    private func addTask() {
        withAnimation {
            storage.addTask(for: tasksList)
        }
    }

    private func deleteTasks(offsets: IndexSet) {
        withAnimation {
            storage.deleteTasks(offsets.map { tasks[$0] })
        }
    }
    
    private func moveTasks(from source: IndexSet, to destination: Int) {
        let orderedTasks: [TaskModel] = tasks.map { $0 }
        storage.moveTasks(orderedTasks, from: source, to: destination)
    }
}

extension TaskListView {
    final class ViewModel: ObservableObject {
        @Published var title: String
        @Published var lastChanged: Date
        
        init(title: String, lastChanged: Date) {
            self.title = title
            self.lastChanged = lastChanged
        }
    }
}
