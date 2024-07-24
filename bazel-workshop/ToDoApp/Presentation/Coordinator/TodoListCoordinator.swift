//
//  TodoListCoordinator.swift
//  ToDoApp
//
//

import Foundation

@MainActor
protocol TodoListCoordinator: AnyObject {
    func openDetails(of item: TodoItem, delegate: TodoItemViewModelDelegate?)
    func openCreationOfTodoItem(delegate: TodoItemViewModelDelegate?)
}
