//
//  NetworkService.swift
//  ToDoApp
//
//

import Foundation

protocol NetworkService {
    var numberOfTasks: Int { get }
    @MainActor func incrementNumberOfTasks()
    @MainActor func decrementNumberOfTasks()
    func loadTodoList() async throws -> [TodoItem]
    func syncTodoList(_ todoList: [TodoItem]) async throws -> [TodoItem]
    func getTodoItem(id: String) async throws -> TodoItem?
    @discardableResult func addTodoItem(_ todoItem: TodoItem) async throws -> TodoItem?
    @discardableResult func changeTodoItem(_ todoItem: TodoItem) async throws -> TodoItem?
    @discardableResult func deleteTodoItem(id: String) async throws -> TodoItem?
}
