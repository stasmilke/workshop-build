//
//  SQLiteCacheServiceImpl.swift
//  ToDoApp
//
//

import Foundation
import SQLite
import CocoaLumberjackSwift

final class SQLiteCacheServiceImpl: CacheService {

    private struct Configuration {
        static let fileName = "TodoDB"
        static let fileExtension = "sqlite3"

        static let todoListTable = Table("TodoList")
        static let idExpression = Expression<UUID>(TodoItem.CodingKeys.id.rawValue)
        static let textExpression = Expression<String>(TodoItem.CodingKeys.text.rawValue)
        static let importanceExpression = Expression<String>(TodoItem.CodingKeys.importance.rawValue)
        static let deadlineExpression = Expression<Date?>(TodoItem.CodingKeys.deadline.rawValue)
        static let isDoneExpression = Expression<Bool>(TodoItem.CodingKeys.isDone.rawValue)
        static let creationDateExpression = Expression<Date>(TodoItem.CodingKeys.creationDate.rawValue)
        static let modificationDateExpression = Expression<Date?>(TodoItem.CodingKeys.modificationDate.rawValue)
        static let textColorExpression = Expression<String>(TodoItem.CodingKeys.textColor.rawValue)
    }

    private var dbConnection: Connection?

    private(set) var todoItems: [UUID: TodoItem] = [:]
    private(set) var isDirty: Bool {
        get {
            UserDefaults.standard.bool(forKey: "isDirty")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "isDirty")
        }
    }

    init() {
        guard let connection = createDatabaseConnection() else { return }
        dbConnection = connection
        createTable(ifNotExists: true)
    }

    // MARK: - Private Methods

    private func createDatabaseConnection() -> Connection? {
        guard let databaseFileURL = getDocumentsDirectory()?
            .appendingPathComponent(Configuration.fileName)
            .appendingPathExtension(Configuration.fileExtension)
        else {
            return nil
        }

        do {
            let connection = try Connection(databaseFileURL.path)
            return connection
        } catch {
            DDLogError(error.localizedDescription)
            return nil
        }
    }

    private func createTable(ifNotExists: Bool) {
        do {
            guard let connection = dbConnection else {
                throw SQLiteError.noConnection
            }
            let createTableQuery = Configuration.todoListTable.create(ifNotExists: ifNotExists) { table in
                table.column(Configuration.idExpression, primaryKey: true)
                table.column(Configuration.textExpression)
                table.column(Configuration.importanceExpression)
                table.column(Configuration.deadlineExpression)
                table.column(Configuration.isDoneExpression)
                table.column(Configuration.creationDateExpression)
                table.column(Configuration.modificationDateExpression)
                table.column(Configuration.textColorExpression)
            }
            try connection.run(createTableQuery)
        } catch {
            DDLogError(error.localizedDescription)
        }
    }

    private func getDocumentsDirectory() -> URL? {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths.first
        return documentsDirectory
    }

    private func mapData(todoRow: Row) -> TodoItem {
        return TodoItem(
            id: todoRow[Configuration.idExpression],
            text: todoRow[Configuration.textExpression],
            importance: Importance(rawValue: todoRow[Configuration.importanceExpression]) ?? Importance.regular,
            deadline: todoRow[Configuration.deadlineExpression],
            isDone: todoRow[Configuration.isDoneExpression],
            creationDate: todoRow[Configuration.creationDateExpression],
            modificationDate: todoRow[Configuration.modificationDateExpression],
            textColor: todoRow[Configuration.textColorExpression]
        )
    }

    // MARK: - Public Methods

    func updateIsDirtyValue(by newValue: Bool) {
        isDirty = newValue
    }

    func loadTodoList() throws -> [TodoItem] {
        guard let connection = dbConnection else {
            throw SQLiteError.noConnection
        }
        var newTodoItems: [UUID: TodoItem] = [:]
        for todoRow in try connection.prepare(Configuration.todoListTable) {
            let todoItem = mapData(todoRow: todoRow)
            newTodoItems[todoItem.id] = todoItem
        }
        todoItems = newTodoItems
        return Array(todoItems.values)
    }

    func updateTodoList(with todoList: [TodoItem]) async throws {
        guard let connection = dbConnection else {
            throw SQLiteError.noConnection
        }
        let deleteAllQuery = Configuration.todoListTable.delete()
        try connection.run(deleteAllQuery)
        var setters: [[Setter]] = []
        todoList.forEach { todoItem in
            let setter = [
                Configuration.idExpression <- todoItem.id,
                Configuration.textExpression <- todoItem.text,
                Configuration.importanceExpression <- todoItem.importance.rawValue,
                Configuration.deadlineExpression <- todoItem.deadline,
                Configuration.isDoneExpression <- todoItem.isDone,
                Configuration.creationDateExpression <- todoItem.creationDate,
                Configuration.modificationDateExpression <- todoItem.modificationDate,
                Configuration.textColorExpression <- todoItem.textColor
            ]
            setters.append(setter)
        }
        if !setters.isEmpty {
            let insertQuery = Configuration.todoListTable.insertMany(or: .replace, setters)
            try connection.run(insertQuery)
        }

        var newTodoItems: [UUID: TodoItem] = [:]
        todoList.forEach { todoItem in
            newTodoItems[todoItem.id] = todoItem
        }
        todoItems = newTodoItems
    }

    func upsertTodoItem(_ todoItem: TodoItem) async throws {
        guard let connection = dbConnection else {
            throw SQLiteError.noConnection
        }
        let upsertQuery = Configuration.todoListTable.upsert(
            Configuration.idExpression <- todoItem.id,
            Configuration.textExpression <- todoItem.text,
            Configuration.importanceExpression <- todoItem.importance.rawValue,
            Configuration.deadlineExpression <- todoItem.deadline,
            Configuration.isDoneExpression <- todoItem.isDone,
            Configuration.creationDateExpression <- todoItem.creationDate,
            Configuration.modificationDateExpression <- todoItem.modificationDate,
            Configuration.textColorExpression <- todoItem.textColor,
            onConflictOf: Configuration.idExpression
        )
        try connection.run(upsertQuery)

        todoItems[todoItem.id] = todoItem
    }

    func deleteTodoItem(with id: UUID) async throws {
        guard let connection = dbConnection else {
            throw SQLiteError.noConnection
        }
        let existingTodoModel = Configuration.todoListTable.filter(Configuration.idExpression == id)
        let deleteQuery = existingTodoModel.delete()
        try connection.run(deleteQuery)

        todoItems.removeValue(forKey: id)
    }

}
