//  TaskListModel+Utils.swift
//  TinyTasks
//
//  Created by Elena Gordienko on 28.01.23.
//  
//

import Foundation

extension TaskListModel {
    var wrappedTitle: String {
        title ?? "Untitled"
    }
}

extension TaskModel: OrderedManagedObject { }
extension TaskListModel: OrderedManagedObject { }
