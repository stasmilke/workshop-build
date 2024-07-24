//
//  SQLiteError.swift
//  ToDoApp
//
//

import Foundation

enum SQLiteError: Error {
    case noConnection
    case notFound
}

extension SQLiteError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .noConnection:
            return "No database connection"
        case .notFound:
            return "Element not found"
        }
    }
}
