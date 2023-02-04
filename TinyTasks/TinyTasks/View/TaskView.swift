//  TaskView.swift
//  TinyTasks
//
//  Created by Elena Gordienko on 21.01.23.
//  
//

import Foundation
import SwiftUI

struct TaskView: View {
    @EnvironmentObject var taskModelStorage: TaskModelStorage
    
    @StateObject var viewModel: ViewModel
    
    @State var task: TaskModel
    
    init(_ receivedTask: TaskModel) {
        _task = .init(initialValue: receivedTask)
        _viewModel = .init(
            wrappedValue: .init(
                text: receivedTask.text ?? "",
                isDone: receivedTask.isDone
            )
        )
    }
    
    var checkBox: some View {
        Image(
            systemName: viewModel.isDone ? "checkmark.square.fill" : "square"
        )
        .foregroundColor(viewModel.isDone ? .green : .secondary)
        .onTapGesture {
            viewModel.isDone.toggle()
        }.onReceive(
            viewModel.$isDone.debounce(for: 0.5, scheduler: RunLoop.main)
        ) { isDone in
            task.isDone = isDone
            taskModelStorage.saveContext()
        }
    }
    
    var textView: some View {
        VStack(alignment: .leading) {
            TextField("Description", text: $viewModel.text, axis: .vertical)
                .onReceive(viewModel.$text.debounce(for: 0.5, scheduler: RunLoop.main)) { text in
                task.text = text
                taskModelStorage.saveContext()
            }
        }
    }
    
    var body: some View {
        HStack {
            checkBox
            textView
        }
        .padding()
    }
}

extension TaskView {
    final class ViewModel: ObservableObject {
        @Published var text: String
        @Published var isDone: Bool
        
        init(text: String, isDone: Bool) {
            self.text = text
            self.isDone = isDone
        }
    }
}
