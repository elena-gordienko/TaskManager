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
            sortDescriptors: [],
            predicate: NSPredicate(format: "list == %@", receivedTaskList)
        )
    }
    
    var body: some View {
        List {
            Section {
                TextField("Task List Name", text: $viewModel.title)
                    .onReceive(viewModel.$title.debounce(for: 0.5, scheduler: RunLoop.main)) { title in
                        tasksList.title = title
                        tasksList.lastChanged = Date()
                        taskModelStorage.saveContext()
                    }
                    .font(.largeTitle)
            }
            Section {
                ForEach(tasks) { task in
                    TaskView(task)
                }
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
             taskModelStorage.addTask(for: tasksList)
         }
     }

     private func deleteTasks(offsets: IndexSet) {
         withAnimation {
             taskModelStorage.deleteTasks(offsets.map { tasks[$0] })
         }
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