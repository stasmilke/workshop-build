//
//  TodoItemJSONTests.swift
//  TodoItemJSONTests
//
//

import XCTest
@testable import ToDoApp

final class TodoItemJSONTests: XCTestCase {

    func testEquivalencyOfJSONValue() throws {
        let item = TodoItem(text: "text", importance: .unimportant, deadline: .now + 100, modificationDate: .now + 10,
                            textColor: "#8989FF")
        let json = try XCTUnwrap(item.json as? [String: Any])
        XCTAssertEqual(json.count, 8)
        XCTAssertTrue(json.values.contains(where: { $0 as? String == item.id.uuidString }))
        XCTAssertTrue(json.values.contains(where: { $0 as? String == item.text }))
        XCTAssertTrue(json.values.contains(where: { $0 as? String == item.importance.rawValue }))
        XCTAssertTrue(json.values.contains(where: { $0 as? Double == item.deadline?.timeIntervalSince1970 }))
        XCTAssertTrue(json.values.contains(where: { $0 as? Bool == item.isDone }))
        XCTAssertTrue(json.values.contains(where: { $0 as? Double == item.creationDate.timeIntervalSince1970 }))
        XCTAssertTrue(json.values.contains(where: { $0 as? Double == item.modificationDate?.timeIntervalSince1970 }))
        XCTAssertTrue(json.values.contains(where: { $0 as? String == item.textColor }))
    }

    func testJSONValueWithAllPropertiesExceptDeadline() throws {
        let item = TodoItem(text: "text", importance: .unimportant, deadline: nil, modificationDate: .now + 10,
                            textColor: "#8989FF")
        let json = try XCTUnwrap(item.json as? [String: Any])
        XCTAssertEqual(json.count, 7)
    }

    func testJSONValueWithAllPropertiesExceptModificationDate() throws {
        let item = TodoItem(text: "text", importance: .unimportant, deadline: .now + 100, modificationDate: nil,
                            textColor: "#8989FF")
        let json = try XCTUnwrap(item.json as? [String: Any])
        XCTAssertEqual(json.count, 7)
    }

    func testJSONValueWithRegularImportance() throws {
        let item = TodoItem(text: "text", importance: .regular, deadline: .now + 100, modificationDate: .now + 10,
                            textColor: "#8989FF")
        let json = try XCTUnwrap(item.json as? [String: Any])
        XCTAssertFalse(json.values.contains(where: { $0 as? String == item.importance.rawValue }))
    }

    func testEquivalencyOfJSONParsing() {
        let item = TodoItem(text: "text", importance: .unimportant, deadline: .now + 100, modificationDate: .now + 10,
                            textColor: "#8989FF")
        var dictionary: [String: Any] = [:]
        dictionary["id"] = item.id.uuidString
        dictionary["text"] = item.text
        dictionary["importance"] = item.importance.rawValue
        dictionary["deadline"] = item.deadline?.timeIntervalSince1970
        dictionary["isDone"] = item.isDone
        dictionary["creationDate"] = item.creationDate.timeIntervalSince1970
        dictionary["modificationDate"] = item.modificationDate?.timeIntervalSince1970
        dictionary["textColor"] = item.textColor

        let parsedItem = TodoItem.parse(json: dictionary)
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

    func testJSONParsingWithInvalidJSONArgument() {
        let dictionary: [Int: Int] = [1: 2, 3: 4]
        let parsedItem = TodoItem.parse(json: dictionary)
        XCTAssertNil(parsedItem)
    }

    func testJSONParsingWithoutImportance() {
        var dictionary: [String: Any] = [:]
        dictionary["id"] = UUID().uuidString
        dictionary["text"] = "text"
        dictionary["deadline"] = Date().timeIntervalSince1970
        dictionary["isDone"] = true
        dictionary["creationDate"] = Date().timeIntervalSince1970
        dictionary["modificationDate"] = Date().timeIntervalSince1970
        dictionary["textColor"] = "#000000"
        let parsedItem = TodoItem.parse(json: dictionary)
        XCTAssertNotNil(parsedItem)
        XCTAssertEqual(parsedItem?.importance, Importance.regular)
    }

    func testJSONParsingWithoutDeadline() {
        var dictionary: [String: Any] = [:]
        dictionary["id"] = UUID().uuidString
        dictionary["text"] = "text"
        dictionary["importance"] = Importance.important.rawValue
        dictionary["isDone"] = true
        dictionary["creationDate"] = Date().timeIntervalSince1970
        dictionary["modificationDate"] = Date().timeIntervalSince1970
        dictionary["textColor"] = "#000000"
        let parsedItem = TodoItem.parse(json: dictionary)
        XCTAssertNotNil(parsedItem)
        XCTAssertNil(parsedItem?.deadline)
    }

    func testJSONParsingWithoutModificationDate() {
        var dictionary: [String: Any] = [:]
        dictionary["id"] = UUID().uuidString
        dictionary["text"] = "text"
        dictionary["importance"] = Importance.important.rawValue
        dictionary["deadline"] = Date().timeIntervalSince1970
        dictionary["isDone"] = true
        dictionary["creationDate"] = Date().timeIntervalSince1970
        dictionary["textColor"] = "#000000"
        let parsedItem = TodoItem.parse(json: dictionary)
        XCTAssertNotNil(parsedItem)
        XCTAssertNil(parsedItem?.modificationDate)
    }

    func testJSONParsingWithInvalidId() {
        var dictionary: [String: Any] = [:]
        dictionary["id"] = "abc"
        dictionary["text"] = "text"
        dictionary["importance"] = Importance.important.rawValue
        dictionary["deadline"] = Date().timeIntervalSince1970
        dictionary["isDone"] = true
        dictionary["creationDate"] = Date().timeIntervalSince1970
        dictionary["modificationDate"] = Date().timeIntervalSince1970
        dictionary["textColor"] = "#000000"
        let parsedItem = TodoItem.parse(json: dictionary)
        XCTAssertNil(parsedItem)
    }

    func testJSONParsingWithoutId() {
        var dictionary: [String: Any] = [:]
        dictionary["text"] = "text"
        dictionary["importance"] = Importance.important.rawValue
        dictionary["deadline"] = Date().timeIntervalSince1970
        dictionary["isDone"] = true
        dictionary["creationDate"] = Date().timeIntervalSince1970
        dictionary["modificationDate"] = Date().timeIntervalSince1970
        dictionary["textColor"] = "#000000"
        let parsedItem = TodoItem.parse(json: dictionary)
        XCTAssertNil(parsedItem)
    }

    func testJSONParsingWithIncorrectImportance() {
        var dictionary: [String: Any] = [:]
        dictionary["id"] = UUID().uuidString
        dictionary["text"] = "text"
        dictionary["importance"] = "123"
        dictionary["deadline"] = Date().timeIntervalSince1970
        dictionary["isDone"] = true
        dictionary["creationDate"] = Date().timeIntervalSince1970
        dictionary["modificationDate"] = Date().timeIntervalSince1970
        dictionary["textColor"] = "#000000"
        let parsedItem = TodoItem.parse(json: dictionary)
        XCTAssertNil(parsedItem)
    }

    func testJSONParsingWithoutText() {
        var dictionary: [String: Any] = [:]
        dictionary["id"] = UUID().uuidString
        dictionary["importance"] = "123"
        dictionary["deadline"] = Date().timeIntervalSince1970
        dictionary["isDone"] = true
        dictionary["creationDate"] = Date().timeIntervalSince1970
        dictionary["modificationDate"] = Date().timeIntervalSince1970
        dictionary["textColor"] = "#000000"
        let parsedItem = TodoItem.parse(json: dictionary)
        XCTAssertNil(parsedItem)
    }

    func testJSONParsingWithIncorrectCreationDate() {
        var dictionary: [String: Any] = [:]
        dictionary["id"] = UUID().uuidString
        dictionary["text"] = "text"
        dictionary["importance"] = Importance.important.rawValue
        dictionary["deadline"] = Date().timeIntervalSince1970
        dictionary["isDone"] = true
        dictionary["creationDate"] = "123"
        dictionary["modificationDate"] = Date().timeIntervalSince1970
        dictionary["textColor"] = "#000000"
        let parsedItem = TodoItem.parse(json: dictionary)
        XCTAssertNil(parsedItem)
    }

    func testJSONParsingWithoutIsDone() {
        var dictionary: [String: Any] = [:]
        dictionary["id"] = UUID().uuidString
        dictionary["text"] = "text"
        dictionary["importance"] = Importance.important.rawValue
        dictionary["deadline"] = Date().timeIntervalSince1970
        dictionary["creationDate"] = Date().timeIntervalSince1970
        dictionary["modificationDate"] = Date().timeIntervalSince1970
        dictionary["textColor"] = "#000000"
        let parsedItem = TodoItem.parse(json: dictionary)
        XCTAssertNil(parsedItem)
    }

    func testJSONParsingWithIncorrectIsDoneValue() {
        var dictionary: [String: Any] = [:]
        dictionary["id"] = UUID().uuidString
        dictionary["text"] = "text"
        dictionary["importance"] = Importance.important.rawValue
        dictionary["deadline"] = Date().timeIntervalSince1970
        dictionary["isDone"] = "123"
        dictionary["creationDate"] = Date().timeIntervalSince1970
        dictionary["modificationDate"] = Date().timeIntervalSince1970
        dictionary["textColor"] = "#000000"
        let parsedItem = TodoItem.parse(json: dictionary)
        XCTAssertNil(parsedItem)
    }

}
