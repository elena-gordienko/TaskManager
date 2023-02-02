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
    
    @FetchRequest(sortDescriptors: [], animation: .default)
    private var tasks: FetchedResults<TaskModel>
    
    var body: some View {
        NavigationView {
            List {
                ForEach(tasks) { task in
                    TaskView(task)
                }
                .onDelete(perform: deleteTasks)
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
    }
    
    private func addTask() {
        withAnimation {
            taskModelStorage.addTask()
        }
    }

    private func deleteTasks(offsets: IndexSet) {
        withAnimation {
            taskModelStorage.deleteTasks(offsets.map { tasks[$0] })
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
