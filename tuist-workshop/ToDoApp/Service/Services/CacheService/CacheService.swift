//
//  CacheService.swift
//  ToDoApp
//
//

import Foundation

protocol CacheService {
    var todoItems: [UUID: TodoItem] { get }
    var isDirty: Bool { get }
    func updateIsDirtyValue(by newValue: Bool)
    func loadTodoList() throws -> [TodoItem]
    func updateTodoList(with todoList: [TodoItem]) async throws
    func upsertTodoItem(_ todoItem: TodoItem) async throws
    func deleteTodoItem(with id: UUID) async throws
}
