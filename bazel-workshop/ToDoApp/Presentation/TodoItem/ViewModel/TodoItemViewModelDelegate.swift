//
//  TodoItemViewModelDelegate.swift
//  ToDoApp
//
//

import Foundation

@MainActor
protocol TodoItemViewModelDelegate: AnyObject {
    func saveToCacheTodoItem(_ newItem: TodoItem)
    func deleteFromCacheTodoItem(with id: UUID)
    func saveToServerTodoItem(_ newItem: TodoItem, isNewItem: Bool)
    func deleteFromServerTodoItem(with id: UUID)
}
