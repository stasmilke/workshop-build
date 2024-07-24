//
//  TodoItemDTO.swift
//  ToDoApp
//
//

import Foundation

struct TodoItemDTO: Codable {
    let status: String
    let element: ElementDTO
    let revision: Int?

    init(status: String = "ok", element: ElementDTO, revision: Int? = nil) {
        self.status = status
        self.element = element
        self.revision = revision
    }
}
