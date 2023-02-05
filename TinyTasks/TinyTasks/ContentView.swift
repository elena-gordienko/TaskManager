//
//  ContentView.swift
//  TinyTasks
//
//  Created by Elena Gordienko on 21.01.23.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @State private var selected: TaskListModel?
    
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(key: "order", ascending: false),
            NSSortDescriptor(key: "lastChanged", ascending: false)
        ],
        animation: .default
    )
    private var taskLists: FetchedResults<TaskListModel>
    
    let storage: any TaskStorage & TaskListStorage
    
    var body: some View {
        #if os(macOS)
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
        .frame(minWidth: 600, minHeight: 400)
        #else
        NavigationStack {
            taskListsView
            .navigationTitle("Task Lists")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem() {
                    Button(action: addTaskList) {
                        Label("Add Task List", systemImage: "plus")
                    }
                }
            }
        }
        #endif
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
                        // this is a deprecated method, but selection doesn't work for `NavigationLink(value:label:)`
                        NavigationLink(
                            destination: TaskListView(taskList, storage: storage),
                            tag: taskList,
                            selection: $selected
                        ) {
                            Text(taskList.wrappedTitle)
                                .multilineTextAlignment(.leading)
                        }
                        .tag(taskList.id)
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
        return ContentView(storage: TaskModelStorage(viewContext: viewContext))
            .environment(\.managedObjectContext, viewContext)
    }
}
