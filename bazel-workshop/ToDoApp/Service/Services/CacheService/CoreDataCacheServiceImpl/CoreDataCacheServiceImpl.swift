//
//  CoreDataCacheServiceImpl.swift
//  ToDoApp
//
//

import Foundation
import CoreData

final class CoreDataCacheServiceImpl: CacheService {

    private(set) var todoItems: [UUID: TodoItem] = [:]
    private(set) var isDirty: Bool {
        get {
            UserDefaults.standard.bool(forKey: "isDirty")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "isDirty")
        }
    }

    private lazy var persistentContainer: NSPersistentContainer = {
        let persistentContainer = NSPersistentContainer(name: "TodoDataModel")
        persistentContainer.loadPersistentStores { _, error in
            guard let error else { return }
        }
        return persistentContainer
    }()

    private var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    // MARK: - Private Methods

    private func getBackgroundContext() -> NSManagedObjectContext {
        return persistentContainer.newBackgroundContext()
    }

    private func save(block: @escaping (NSManagedObjectContext) throws -> Void) async throws {
        let backgroundContext = getBackgroundContext()
        try await backgroundContext.perform {
            try block(backgroundContext)
            if backgroundContext.hasChanges {
                try backgroundContext.save()
            }
        }
    }

    private func fetchTodoItem(with id: UUID, context: NSManagedObjectContext) -> TodoItemDB? {
        let fetchRequest = TodoItemDB.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        return try? context.fetch(fetchRequest).first
    }

    private func mapData(todoItemDB: TodoItemDB) -> TodoItem? {
        guard
            let id = todoItemDB.id,
            let text = todoItemDB.text,
            let importanceRawValue = todoItemDB.importance,
            let importance = Importance(rawValue: importanceRawValue),
            let creationDate = todoItemDB.creationDate,
            let textColor = todoItemDB.textColor
        else {
            return nil
        }

        return TodoItem(
            id: id,
            text: text,
            importance: importance,
            deadline: todoItemDB.deadline,
            isDone: todoItemDB.isDone,
            creationDate: creationDate,
            modificationDate: todoItemDB.modificationDate,
            textColor: textColor
        )
    }

    // MARK: - Public Methods

    func updateIsDirtyValue(by newValue: Bool) {
        isDirty = newValue
    }

    func loadTodoList() throws -> [TodoItem] {
        let fetchRequest = TodoItemDB.fetchRequest()
        let dbData: [TodoItemDB] = try viewContext.fetch(fetchRequest)

        var newTodoItems: [UUID: TodoItem] = [:]
        dbData.forEach { todoItemDB in
            if let todoItem = mapData(todoItemDB: todoItemDB) {
                newTodoItems[todoItem.id] = todoItem
            }
        }
        todoItems = newTodoItems
        return Array(todoItems.values)
    }

    func updateTodoList(with todoList: [TodoItem]) async throws {
        try await save { context in
            let fetchRequest = TodoItemDB.fetchRequest()
            let existingDBData: [TodoItemDB] = try context.fetch(fetchRequest)
            existingDBData.forEach { todoItemDB in
                context.delete(todoItemDB)
            }
            todoList.forEach { todoItem in
                let todoItemDB = TodoItemDB(context: context)
                todoItemDB.id = todoItem.id
                todoItemDB.text = todoItem.text
                todoItemDB.importance = todoItem.importance.rawValue
                todoItemDB.deadline = todoItem.deadline
                todoItemDB.isDone = todoItem.isDone
                todoItemDB.creationDate = todoItem.creationDate
                todoItemDB.modificationDate = todoItem.modificationDate
                todoItemDB.textColor = todoItem.textColor
            }
        }

        var newTodoItems: [UUID: TodoItem] = [:]
        todoList.forEach { todoItem in
            newTodoItems[todoItem.id] = todoItem
        }
        todoItems = newTodoItems
    }

    func deleteTodoItem(with id: UUID) async throws {
        try await save { [weak self] context in
            if let todoItemDB = self?.fetchTodoItem(with: id, context: context) {
                context.delete(todoItemDB)
            }
        }
        todoItems.removeValue(forKey: id)
    }

    func upsertTodoItem(_ todoItem: TodoItem) async throws {
        try await save { [weak self] context in
            var todoItemDB: TodoItemDB
            if let existingTodoItemDB = self?.fetchTodoItem(with: todoItem.id, context: context) {
                todoItemDB = existingTodoItemDB
            } else {
                todoItemDB = TodoItemDB(context: context)
                todoItemDB.id = todoItem.id
            }
            todoItemDB.text = todoItem.text
            todoItemDB.importance = todoItem.importance.rawValue
            todoItemDB.deadline = todoItem.deadline
            todoItemDB.isDone = todoItem.isDone
            todoItemDB.creationDate = todoItem.creationDate
            todoItemDB.modificationDate = todoItem.modificationDate
            todoItemDB.textColor = todoItem.textColor
        }

        todoItems[todoItem.id] = todoItem
    }

}
