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
    
    @State private var selected: TaskListModel?
    
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(key: "order", ascending: false),
            NSSortDescriptor(key: "lastChanged", ascending: false)
        ],
        animation: .default
    )
    private var taskLists: FetchedResults<TaskListModel>
    
    var storage: any TaskListStorage { taskModelStorage }
    
    var body: some View {
        #if os(macOS)
        macOSView.frame(minWidth: 600, minHeight: 400)
        #else
        iOSView
        #endif
    }
    
    var macOSView: some View {
        NavigationView {
            taskListsView
        }
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: toggleSidebar, label: {
                    Image(systemName: "sidebar.leading")
                })
            }
        }
    }
    
    var iOSView: some View {
        NavigationStack {
            taskListsView
            .navigationTitle("Task Lists")
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                #endif
                ToolbarItem() {
                    Button(action: addTaskList) {
                        Label("Add Task List", systemImage: "plus")
                    }
                }
            }
        }
    }
    
    var controlButtons: some View {
        HStack {
            Button(action: addTaskList) {
                Label("Add", systemImage: "plus")
            }
            Button(action: {
                if let selection = selected {
                    withAnimation {
                        storage.deleteTaskLists([selection])
                        selected = nil
                    }
                }
            }, label: {
                Label("Delete", systemImage: "trash")
            })
            .disabled($selected.wrappedValue == nil)
        }.padding()
    }
    
    var taskListsView: some View {
        VStack {
            if taskLists.isEmpty {
                Text("Add task list by clicking +").padding()
            } else {
                List(selection: $selected) {
                    ForEach(taskLists) { taskList in
                        NavigationLink(taskList.wrappedTitle) {
                            TaskListView(taskList)
                        }
                        .swipeActions {
                            Button("Delete", role: .destructive) {
                                deleteTaskList(taskList)
                            }
                        }
                    }
                    .onMove(perform: moveTaskLists)
                    .onDelete(perform: deleteTaskLists)
                }
                
                #if os(macOS)
                .listStyle(.sidebar)
                .frame(minWidth: 160)
                #endif
            }
            Spacer()
            #if os(macOS)
            controlButtons
            #endif
        }
    }
}

extension ContentView {
    private func toggleSidebar() {
        #if os(iOS)
        #else
        NSApp
            .keyWindow?
            .firstResponder?
            .tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
        #endif
    }
    
    private func addTaskList() {
        withAnimation {
            storage.addTaskList(number: taskLists.count)
        }
    }
    
    private func deleteTaskList(_ taskList: TaskListModel) {
        withAnimation {
            storage.deleteTaskLists([taskList])
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
        let viewContext = PersistenceController.preview.container.viewContext
        return ContentView()
            .environment(\.managedObjectContext, viewContext)
            .environmentObject(TaskModelStorage(viewContext: viewContext))
    }
}
