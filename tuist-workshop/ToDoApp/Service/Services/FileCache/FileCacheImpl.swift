//
//  FileCacheImpl.swift
//  ToDoList
//
//

import Foundation

final class FileCacheImpl: FileCache {

    private(set) var todoItems: [UUID: TodoItem] = [:]
    private(set) var isDirty: Bool {
        get {
            UserDefaults.standard.bool(forKey: "isDirty")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "isDirty")
        }
    }

    // MARK: - Public Methods

    func updateIsDirtyValue(by newValue: Bool) {
        isDirty = newValue
    }

    func addItem(_ item: TodoItem) {
        todoItems[item.id] = item
    }

    func deleteItem(with id: UUID) {
        todoItems.removeValue(forKey: id)
    }

    func saveItemsToJSON(fileName: String) throws {
        let itemsArray = todoItems.values.map(\.json)
        let jsonData = try JSONSerialization.data(withJSONObject: itemsArray, options: [.prettyPrinted, .sortedKeys])
        try saveDataToDocuments(jsonData, fileName: "\(fileName).json")
    }

    func loadItemsFromJSON(fileName: String) throws {
        let jsonData = try loadDataFromDocuments(fileName: "\(fileName).json")
        let decodedData = try JSONSerialization.jsonObject(with: jsonData, options: [])
        guard let itemsArray = decodedData as? [[String: Any]] else { return }

        var newTodoItems: [UUID: TodoItem] = [:]
        itemsArray.forEach { dictionary in
            if let item = TodoItem.parse(json: dictionary) {
                newTodoItems[item.id] = item
            }
        }
        todoItems = newTodoItems
    }

    func saveItemsToCSV(fileName: String) throws {
        var csvString = TodoItem.csvTitles
        csvString.append(TodoItem.csvRowsDelimiter)
        todoItems.values.forEach { item in
            csvString.append(item.csv)
            csvString.append(TodoItem.csvRowsDelimiter)
        }
        try saveStringToDocuments(csvString, fileName: "\(fileName).csv")
    }

    func loadItemsFromCSV(fileName: String) throws {
        let csvString = try loadStringFromDocuments(fileName: "\(fileName).csv")
        var rows = csvString.components(separatedBy: TodoItem.csvRowsDelimiter)
        rows.removeFirst()
        var newTodoItems: [UUID: TodoItem] = [:]
        rows.forEach { row in
            if let item = TodoItem.parse(csv: row) {
                newTodoItems[item.id] = item
            }
        }
        todoItems = newTodoItems
    }

    // MARK: - Private Methods

    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }

    private func saveDataToDocuments(_ data: Data, fileName: String) throws {
        let fileURL = getDocumentsDirectory().appendingPathComponent(fileName)
        try data.write(to: fileURL)
    }

    private func loadDataFromDocuments(fileName: String) throws -> Data {
        let fileURL = getDocumentsDirectory().appendingPathComponent(fileName)
        return try Data(contentsOf: fileURL)
    }

    private func saveStringToDocuments(_ string: String, fileName: String) throws {
        let fileURL = getDocumentsDirectory().appendingPathComponent(fileName)
        try string.write(to: fileURL, atomically: true, encoding: .utf8)
    }

    private func loadStringFromDocuments(fileName: String) throws -> String {
        let fileURL = getDocumentsDirectory().appendingPathComponent(fileName)
        return try String(contentsOf: fileURL, encoding: .utf8)
    }

}
