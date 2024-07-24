//
//  RequestError.swift
//  ToDoApp
//
//

import Foundation

enum RequestError: Error {
    case wrongURL(URLComponents)
    case unexpectedResponse
    case badRequest
    case wrongAuth
    case notFound
    case serverError
    case unexpectedStatusCode(Int)
}

extension RequestError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .wrongURL(let urlComponents):
            return "Could not construct url with components: \(urlComponents)"
        case .unexpectedResponse:
            return "Unexpected response from server"
        case .badRequest:
            return "Wrong request or unsynchronized data"
        case .wrongAuth:
            return "Wrong authorization"
        case .notFound:
            return "Element not found"
        case .serverError:
            return "Server error"
        case .unexpectedStatusCode(let code):
            return "Unexpected status code: \(code)"
        }
    }
}
