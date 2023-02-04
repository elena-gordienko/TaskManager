//
//  ContentView.swift
//  TinyTasks
//
//  Created by Elena Gordienko on 21.01.23.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @EnvironmentObject var taskModelStorage: TaskModelStorage
    
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(key: "order", ascending: true),
            NSSortDescriptor(key: "lastChanged", ascending: false)
        ],
        animation: .default
    )
    private var taskLists: FetchedResults<TaskListModel>
    
    var storage: any TaskListStorage { taskModelStorage }
    
    @ViewBuilder
    var taskListsView: some View {
        if taskLists.isEmpty {
            Text("Add task list by clicking +")
        } else {
            list
        }
    }
    
    var list: some View {
        List {
            ForEach(taskLists) { taskList in
                NavigationLink(taskList.wrappedTitle, value: taskList)
            }
            .onMove(perform: moveTaskLists)
            .onDelete(perform: deleteTaskLists)
        }
    }
    
    var body: some View {
        NavigationStack {
            taskListsView.navigationDestination(for: TaskListModel.self) { taskList in
                TaskListView(taskList)
            }
            .navigationTitle("Task Lists")
            .toolbar {
#if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
#endif
                ToolbarItem {
                    Button(action: addTaskList) {
                        Label("Add Task List", systemImage: "plus")
                    }
                }
            }
        }
    }
}

extension ContentView {
    private func addTaskList() {
        withAnimation {
            storage.addTaskList(number: taskLists.count)
        }
    }

    private func deleteTaskLists(offsets: IndexSet) {
        withAnimation {
            storage.deleteTaskLists(offsets.map { taskLists[$0] })
        }
    }
    
    private func moveTaskLists(from source: IndexSet, to destination: Int) {
        let orderedLists: [TaskListModel] = taskLists.map { $0 }
        storage.moveTasksList(orderedLists, from: source, to: destination)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
