//
//  TodoItem.swift
//  ToDoList
//
//

import Foundation

struct TodoItem: Hashable {

    enum CodingKeys: String, CodingKey {
        case id
        case text
        case importance
        case deadline
        case isDone = "done"
        case creationDate = "created_at"
        case modificationDate = "changed_at"
        case textColor = "color"
    }

    let id: UUID
    let text: String
    let importance: Importance
    let deadline: Date?
    let isDone: Bool
    let creationDate: Date
    let modificationDate: Date?
    let textColor: String

    init(
        id: UUID = UUID(),
        text: String,
        importance: Importance,
        deadline: Date?,
        isDone: Bool = false,
        creationDate: Date = Date(),
        modificationDate: Date? = nil,
        textColor: String
    ) {
        self.id = id
        self.text = text
        self.importance = importance
        self.deadline = deadline
        self.isDone = isDone
        self.creationDate = creationDate
        self.modificationDate = modificationDate
        self.textColor = textColor
    }

}

// MARK: - JSON Parsing

extension TodoItem {

    var json: Any {
        var dictionary: [String: Any] = [:]
        dictionary[CodingKeys.id.rawValue] = id.uuidString
        dictionary[CodingKeys.text.rawValue] = text
        if importance != .regular {
            dictionary[CodingKeys.importance.rawValue] = importance.rawValue
        }
        dictionary[CodingKeys.deadline.rawValue] = deadline?.timeIntervalSince1970
        dictionary[CodingKeys.isDone.rawValue] = isDone
        dictionary[CodingKeys.creationDate.rawValue] = creationDate.timeIntervalSince1970
        dictionary[CodingKeys.modificationDate.rawValue] = modificationDate?.timeIntervalSince1970
        dictionary[CodingKeys.textColor.rawValue] = textColor
        return dictionary
    }

    static func parse(json: Any) -> TodoItem? {
        guard
            let dictionary = json as? [String: Any],
            let idString = dictionary[CodingKeys.id.rawValue] as? String,
            let id = UUID(uuidString: idString),
            let text = dictionary[CodingKeys.text.rawValue] as? String,
            let importance = (dictionary[CodingKeys.importance.rawValue] as? String)
                .map(Importance.init(rawValue:)) ?? Importance.regular,
            let isDone = dictionary[CodingKeys.isDone.rawValue] as? Bool,
            let creationDateTimeInterval = dictionary[CodingKeys.creationDate.rawValue] as? TimeInterval,
            let textColor = dictionary[CodingKeys.textColor.rawValue] as? String
        else { return nil }

        let creationDate = Date(timeIntervalSince1970: creationDateTimeInterval)
        let deadline = (dictionary[CodingKeys.deadline.rawValue] as? TimeInterval)
            .map { interval in Date(timeIntervalSince1970: interval) }
        let modificationDate = (dictionary[CodingKeys.modificationDate.rawValue] as? TimeInterval)
            .map { interval in Date(timeIntervalSince1970: interval) }

        return TodoItem(
            id: id,
            text: text,
            importance: importance,
            deadline: deadline,
            isDone: isDone,
            creationDate: creationDate,
            modificationDate: modificationDate,
            textColor: textColor
        )
    }

}

// MARK: - CSV Parsing

extension TodoItem {

    static let csvColumnsDelimiter = ";"
    static let csvRowsDelimiter = "\r"

    static var csvTitles: String {
        var values = [String]()
        values.append(CodingKeys.id.rawValue)
        values.append(CodingKeys.text.rawValue)
        values.append(CodingKeys.importance.rawValue)
        values.append(CodingKeys.deadline.rawValue)
        values.append(CodingKeys.isDone.rawValue)
        values.append(CodingKeys.creationDate.rawValue)
        values.append(CodingKeys.modificationDate.rawValue)
        values.append(CodingKeys.textColor.rawValue)
        return values.joined(separator: TodoItem.csvColumnsDelimiter)
    }

    var csv: String {
        var values = [String]()
        values.append(id.uuidString)
        values.append(text)
        values.append(importance != .regular ? importance.rawValue : "")
        values.append(deadline?.timeIntervalSince1970.description ?? "")
        values.append((isDone ? 1 : 0).description)
        values.append(creationDate.timeIntervalSince1970.description)
        values.append(modificationDate?.timeIntervalSince1970.description ?? "")
        values.append(textColor)
        return values.joined(separator: TodoItem.csvColumnsDelimiter)
    }

    static func parse(csv: String) -> TodoItem? {
        let columns = csv.components(separatedBy: TodoItem.csvColumnsDelimiter)

        guard
            columns.count == 8,
            let id = UUID(uuidString: columns[0]),
            let importance = (columns[2].isEmpty ? nil : columns[2]).map(Importance.init(rawValue:)) ?? .regular,
            let isDoneInt = Int(columns[4]),
            isDoneInt == 0 || isDoneInt == 1,
            let creationDateTimeInterval = TimeInterval(columns[5])
        else { return nil }

        let text = columns[1]
        let isDone = isDoneInt != 0
        let creationDate = Date(timeIntervalSince1970: creationDateTimeInterval)
        let deadline = TimeInterval(columns[3]).map { interval in Date(timeIntervalSince1970: interval) }
        let modificationDate = TimeInterval(columns[6]).map { interval in Date(timeIntervalSince1970: interval) }
        let textColor = columns[7]

        return TodoItem(
            id: id,
            text: text,
            importance: importance,
            deadline: deadline,
            isDone: isDone,
            creationDate: creationDate,
            modificationDate: modificationDate,
            textColor: textColor
        )
    }

}
