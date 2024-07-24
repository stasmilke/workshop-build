//
//  ElementDTO.swift
//  ToDoApp
//
//

import Foundation

struct ElementDTO: Codable {
    let id: String
    let text: String
    let importance: String
    let deadline: Int?
    let done: Bool
    let color: String?
    let creationDate: Int
    let modificationDate: Int
    let lastUpdatedBy: String

    private enum CodingKeys: String, CodingKey {
        case id
        case text
        case importance
        case deadline
        case done
        case color
        case creationDate = "created_at"
        case modificationDate = "changed_at"
        case lastUpdatedBy = "last_updated_by"
    }
}
