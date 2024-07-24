//
//  TodoItemCSVTests.swift
//  ToDoAppTests
//
//

import XCTest
@testable import ToDoApp

final class TodoItemCSVTests: XCTestCase {

    func testEquivalencyOfCSVValue() {
        let item = TodoItem(text: "text", importance: .unimportant, deadline: .now + 100, modificationDate: .now + 10,
                            textColor: "#8989FF")
        let csvString = item.csv
        let columns = csvString.components(separatedBy: TodoItem.csvColumnsDelimiter)
        XCTAssertEqual(columns.count, 8)
        XCTAssertEqual(columns[0], item.id.uuidString)
        XCTAssertEqual(columns[1], item.text)
        XCTAssertEqual(columns[2], item.importance.rawValue)
        XCTAssertEqual(Double(columns[3]), item.deadline?.timeIntervalSince1970)
        XCTAssertEqual(Int(columns[4]) != 0, item.isDone)
        XCTAssertEqual(Double(columns[5]), item.creationDate.timeIntervalSince1970)
        XCTAssertEqual(Double(columns[6]), item.modificationDate?.timeIntervalSince1970)
        XCTAssertEqual(columns[7], item.textColor)
    }

    func testCSVValueWithAllPropertiesExceptDeadline() {
        let item = TodoItem(text: "text", importance: .unimportant, deadline: nil, modificationDate: .now + 10,
                            textColor: "#8989FF")
        let csvString = item.csv
        let columns = csvString.components(separatedBy: TodoItem.csvColumnsDelimiter)
        XCTAssertEqual(columns.count, 8)
        XCTAssertTrue(columns[3].isEmpty)
    }

    func testCSVValueWithAllPropertiesExceptModificationDate() {
        let item = TodoItem(text: "text", importance: .unimportant, deadline: .now + 100, modificationDate: nil,
                            textColor: "#8989FF")
        let csvString = item.csv
        let columns = csvString.components(separatedBy: TodoItem.csvColumnsDelimiter)
        XCTAssertEqual(columns.count, 8)
        XCTAssertTrue(columns[6].isEmpty)
    }

    func testCSVValueWithRegularImportance() {
        let item = TodoItem(text: "text", importance: .regular, deadline: .now + 100, modificationDate: .now + 10,
                            textColor: "#8989FF")
        let csvString = item.csv
        let columns = csvString.components(separatedBy: TodoItem.csvColumnsDelimiter)
        XCTAssertEqual(columns.count, 8)
        XCTAssertTrue(columns[2].isEmpty)
    }

    func testEquivalencyOfCSVParsing() throws {
        let item = TodoItem(text: "text", importance: .unimportant, deadline: .now + 100, modificationDate: .now + 10,
                            textColor: "#8989FF")
        var csv: String = String()
        csv.append(item.id.uuidString)
        csv.append(TodoItem.csvColumnsDelimiter)
        csv.append(item.text)
        csv.append(TodoItem.csvColumnsDelimiter)
        csv.append(item.importance.rawValue)
        csv.append(TodoItem.csvColumnsDelimiter)
        csv.append(try XCTUnwrap(item.deadline?.timeIntervalSince1970.description))
        csv.append(TodoItem.csvColumnsDelimiter)
        csv.append((item.isDone ? 1 : 0).description)
        csv.append(TodoItem.csvColumnsDelimiter)
        csv.append(item.creationDate.timeIntervalSince1970.description)
        csv.append(TodoItem.csvColumnsDelimiter)
        csv.append(try XCTUnwrap(item.modificationDate?.timeIntervalSince1970.description))
        csv.append(TodoItem.csvColumnsDelimiter)
        csv.append(item.textColor)

        let parsedItem = TodoItem.parse(csv: csv)
        XCTAssertNotNil(parsedItem)
        XCTAssertEqual(parsedItem?.id, item.id)
        XCTAssertEqual(parsedItem?.text, item.text)
        XCTAssertEqual(parsedItem?.importance, item.importance)
        XCTAssertEqual(parsedItem?.deadline?.timeIntervalSince1970, item.deadline?.timeIntervalSince1970)
        XCTAssertEqual(parsedItem?.isDone, item.isDone)
        XCTAssertEqual(parsedItem?.creationDate.timeIntervalSince1970, item.creationDate.timeIntervalSince1970)
        XCTAssertEqual(parsedItem?.modificationDate?.timeIntervalSince1970,
                       item.modificationDate?.timeIntervalSince1970)
        XCTAssertEqual(parsedItem?.textColor, item.textColor)
    }

    func testCSVParsingWithInvalidCSVArgument() {
        let invalidString = "abcdef12345"
        let parsedItem = TodoItem.parse(csv: invalidString)
        XCTAssertNil(parsedItem)
    }

    func testCSVParsingWithIncorrectColumnsCount() {
        var csv: String = String()
        csv.append(UUID().uuidString)
        csv.append(TodoItem.csvColumnsDelimiter)
        csv.append("text")
        csv.append(TodoItem.csvColumnsDelimiter)
        csv.append(Importance.important.rawValue)

        let parsedItem = TodoItem.parse(csv: csv)
        XCTAssertNil(parsedItem)
    }

    func testCSVParsingWithoutImportance() {
        var csv: String = String()
        csv.append(UUID().uuidString)
        csv.append(TodoItem.csvColumnsDelimiter)
        csv.append("text")
        csv.append(TodoItem.csvColumnsDelimiter)
        csv.append(TodoItem.csvColumnsDelimiter)
        csv.append(Date().timeIntervalSince1970.description)
        csv.append(TodoItem.csvColumnsDelimiter)
        csv.append("1")
        csv.append(TodoItem.csvColumnsDelimiter)
        csv.append(Date().timeIntervalSince1970.description)
        csv.append(TodoItem.csvColumnsDelimiter)
        csv.append(Date().timeIntervalSince1970.description)
        csv.append(TodoItem.csvColumnsDelimiter)
        csv.append("#8989FF")

        let parsedItem = TodoItem.parse(csv: csv)
        XCTAssertNotNil(parsedItem)
        XCTAssertEqual(parsedItem?.importance, Importance.regular)
    }

    func testCSVParsingWithoutDeadline() {
        var csv: String = String()
        csv.append(UUID().uuidString)
        csv.append(TodoItem.csvColumnsDelimiter)
        csv.append("text")
        csv.append(TodoItem.csvColumnsDelimiter)
        csv.append(Importance.important.rawValue)
        csv.append(TodoItem.csvColumnsDelimiter)
        csv.append(TodoItem.csvColumnsDelimiter)
        csv.append("1")
        csv.append(TodoItem.csvColumnsDelimiter)
        csv.append(Date().timeIntervalSince1970.description)
        csv.append(TodoItem.csvColumnsDelimiter)
        csv.append(Date().timeIntervalSince1970.description)
        csv.append(TodoItem.csvColumnsDelimiter)
        csv.append("#8989FF")

        let parsedItem = TodoItem.parse(csv: csv)
        XCTAssertNotNil(parsedItem)
        XCTAssertNil(parsedItem?.deadline)
    }

    func testCSVParsingWithoutModificationDate() throws {
        var csv: String = String()
        csv.append(UUID().uuidString)
        csv.append(TodoItem.csvColumnsDelimiter)
        csv.append("text")
        csv.append(TodoItem.csvColumnsDelimiter)
        csv.append(Importance.important.rawValue)
        csv.append(TodoItem.csvColumnsDelimiter)
        csv.append(Date().timeIntervalSince1970.description)
        csv.append(TodoItem.csvColumnsDelimiter)
        csv.append("1")
        csv.append(TodoItem.csvColumnsDelimiter)
        csv.append(Date().timeIntervalSince1970.description)
        csv.append(TodoItem.csvColumnsDelimiter)
        csv.append(TodoItem.csvColumnsDelimiter)
        csv.append("#8989FF")

        let parsedItem = TodoItem.parse(csv: csv)
        XCTAssertNotNil(parsedItem)
        XCTAssertNil(parsedItem?.modificationDate)
    }

    func testCSVParsingWithoutId() throws {
        var csv: String = String()
        csv.append(TodoItem.csvColumnsDelimiter)
        csv.append("text")
        csv.append(TodoItem.csvColumnsDelimiter)
        csv.append(Importance.important.rawValue)
        csv.append(TodoItem.csvColumnsDelimiter)
        csv.append(Date().timeIntervalSince1970.description)
        csv.append(TodoItem.csvColumnsDelimiter)
        csv.append("1")
        csv.append(TodoItem.csvColumnsDelimiter)
        csv.append(Date().timeIntervalSince1970.description)
        csv.append(TodoItem.csvColumnsDelimiter)
        csv.append(Date().timeIntervalSince1970.description)
        csv.append(TodoItem.csvColumnsDelimiter)
        csv.append("#8989FF")

        let parsedItem = TodoItem.parse(csv: csv)
        XCTAssertNil(parsedItem)
    }

    func testCSVParsingWithIncorrectImportance() {
        var csv: String = String()
        csv.append(UUID().uuidString)
        csv.append(TodoItem.csvColumnsDelimiter)
        csv.append("text")
        csv.append(TodoItem.csvColumnsDelimiter)
        csv.append("123")
        csv.append(TodoItem.csvColumnsDelimiter)
        csv.append(Date().timeIntervalSince1970.description)
        csv.append(TodoItem.csvColumnsDelimiter)
        csv.append("1")
        csv.append(TodoItem.csvColumnsDelimiter)
        csv.append(Date().timeIntervalSince1970.description)
        csv.append(TodoItem.csvColumnsDelimiter)
        csv.append(Date().timeIntervalSince1970.description)
        csv.append(TodoItem.csvColumnsDelimiter)
        csv.append("#8989FF")

        let parsedItem = TodoItem.parse(csv: csv)
        XCTAssertNil(parsedItem)
    }

    func testCSVParsingWithIncorrectCreationDate() throws {
        var csv: String = String()
        csv.append(UUID().uuidString)
        csv.append(TodoItem.csvColumnsDelimiter)
        csv.append("text")
        csv.append(TodoItem.csvColumnsDelimiter)
        csv.append(Importance.important.rawValue)
        csv.append(TodoItem.csvColumnsDelimiter)
        csv.append(Date().timeIntervalSince1970.description)
        csv.append(TodoItem.csvColumnsDelimiter)
        csv.append("1")
        csv.append(TodoItem.csvColumnsDelimiter)
        csv.append("")
        csv.append(TodoItem.csvColumnsDelimiter)
        csv.append(Date().timeIntervalSince1970.description)
        csv.append(TodoItem.csvColumnsDelimiter)
        csv.append("#8989FF")

        let parsedItem = TodoItem.parse(csv: csv)
        XCTAssertNil(parsedItem)
    }

    func testCSVParsingWithoutIsDone() throws {
        var csv: String = String()
        csv.append(UUID().uuidString)
        csv.append(TodoItem.csvColumnsDelimiter)
        csv.append("text")
        csv.append(TodoItem.csvColumnsDelimiter)
        csv.append(Importance.important.rawValue)
        csv.append(TodoItem.csvColumnsDelimiter)
        csv.append(Date().timeIntervalSince1970.description)
        csv.append(TodoItem.csvColumnsDelimiter)
        csv.append(TodoItem.csvColumnsDelimiter)
        csv.append(Date().timeIntervalSince1970.description)
        csv.append(TodoItem.csvColumnsDelimiter)
        csv.append(Date().timeIntervalSince1970.description)
        csv.append(TodoItem.csvColumnsDelimiter)
        csv.append("#8989FF")

        let parsedItem = TodoItem.parse(csv: csv)
        XCTAssertNil(parsedItem)
    }

    func testCSVParsingWithIncorrectIsDoneValue() throws {
        var csv: String = String()
        csv.append(UUID().uuidString)
        csv.append(TodoItem.csvColumnsDelimiter)
        csv.append("text")
        csv.append(TodoItem.csvColumnsDelimiter)
        csv.append(Importance.important.rawValue)
        csv.append(TodoItem.csvColumnsDelimiter)
        csv.append(Date().timeIntervalSince1970.description)
        csv.append(TodoItem.csvColumnsDelimiter)
        csv.append("12345")
        csv.append(TodoItem.csvColumnsDelimiter)
        csv.append(Date().timeIntervalSince1970.description)
        csv.append(TodoItem.csvColumnsDelimiter)
        csv.append(Date().timeIntervalSince1970.description)
        csv.append(TodoItem.csvColumnsDelimiter)
        csv.append("#8989FF")

        let parsedItem = TodoItem.parse(csv: csv)
        XCTAssertNil(parsedItem)
    }

}
