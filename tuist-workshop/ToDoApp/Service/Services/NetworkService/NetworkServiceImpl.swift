//
//  NetworkServiceImpl.swift
//  ToDoApp
//
//

import Foundation

final class NetworkServiceImpl: NetworkService {

    private struct Configuration {
        static let scheme = "foo"
        static let host = "foo"
        static let path = "foo"
        static let token = "foo"
    }

    private(set) var numberOfTasks = 0
    private let urlSession: URLSession
    private var revision: Int = 0
    private let deviceID: String

    init(urlSession: URLSession = URLSession.shared, deviceID: String) {
        self.urlSession = urlSession
        self.deviceID = deviceID
    }

    // MARK: - Public Methods

    @MainActor
    func incrementNumberOfTasks() {
        numberOfTasks += 1
    }

    @MainActor
    func decrementNumberOfTasks() {
        numberOfTasks -= 1
    }

    func loadTodoList() async throws -> [TodoItem] {
        let request = try makeGetRequest(path: "/\(Configuration.path)/list")
        let (data, _) = try await performRequest(request)
        let response = try JSONDecoder().decode(TodoListDTO.self, from: data)
        if let revision = response.revision {
            self.revision = revision
        }
        return response.list.compactMap(mapData(element:))
    }

    func syncTodoList(_ todoList: [TodoItem]) async throws -> [TodoItem] {
        let todoListDTO = TodoListDTO(list: todoList.map { mapData(todoItem: $0) })
        let requestBody = try JSONEncoder().encode(todoListDTO)
        let request = try makePatchRequest(path: "/\(Configuration.path)/list", body: requestBody)
        let (data, _) = try await performRequest(request)
        let response = try JSONDecoder().decode(TodoListDTO.self, from: data)
        if let revision = response.revision {
            self.revision = revision
        }
        return response.list.compactMap(mapData(element:))
    }

    func getTodoItem(id: String) async throws -> TodoItem? {
        let request = try makeGetRequest(path: "/\(Configuration.path)/list/\(id)")
        let (data, _) = try await performRequest(request)
        let response = try JSONDecoder().decode(TodoItemDTO.self, from: data)
        if let revision = response.revision {
            self.revision = revision
        }
        return mapData(element: response.element)
    }

    @discardableResult
    func addTodoItem(_ todoItem: TodoItem) async throws -> TodoItem? {
        let todoItemDTO = TodoItemDTO(element: mapData(todoItem: todoItem))
        let requestBody = try JSONEncoder().encode(todoItemDTO)
        let request = try makePostRequest(path: "/\(Configuration.path)/list", body: requestBody)
        let (data, _) = try await performRequest(request)
        let response = try JSONDecoder().decode(TodoItemDTO.self, from: data)
        if let revision = response.revision {
            self.revision = revision
        }
        return mapData(element: response.element)
    }

    @discardableResult
    func changeTodoItem(_ todoItem: TodoItem) async throws -> TodoItem? {
        let todoItemDTO = TodoItemDTO(element: mapData(todoItem: todoItem))
        let requestBody = try JSONEncoder().encode(todoItemDTO)
        let request = try makePutRequest(
            path: "/\(Configuration.path)/list/\(todoItem.id.uuidString)",
            body: requestBody
        )
        let (data, _) = try await performRequest(request)
        let response = try JSONDecoder().decode(TodoItemDTO.self, from: data)
        if let revision = response.revision {
            self.revision = revision
        }
        return mapData(element: response.element)
    }

    @discardableResult
    func deleteTodoItem(id: String) async throws -> TodoItem? {
        let request = try makeDeleteRequest(path: "/\(Configuration.path)/list/\(id)")
        let (data, _) = try await performRequest(request)
        let response = try JSONDecoder().decode(TodoItemDTO.self, from: data)
        if let revision = response.revision {
            self.revision = revision
        }
        return mapData(element: response.element)
    }

    // MARK: - Private Methods

    private func makeURL(path: String) throws -> URL {
        var urlComponents = URLComponents()
        urlComponents.scheme = Configuration.scheme
        urlComponents.host = Configuration.host
        urlComponents.path = path

        guard let url = urlComponents.url else {
            throw RequestError.wrongURL(urlComponents)
        }
        return url
    }

    private func makeGetRequest(path: String) throws -> URLRequest {
        let url = try makeURL(path: path)
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(Configuration.token)", forHTTPHeaderField: "Authorization")
        return request
    }

    private func makePatchRequest(path: String, body: Data) throws -> URLRequest {
        let url = try makeURL(path: path)
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("Bearer \(Configuration.token)", forHTTPHeaderField: "Authorization")
        request.setValue("\(revision)", forHTTPHeaderField: "X-Last-Known-Revision")
        request.httpBody = body
        return request
    }

    private func makePostRequest(path: String, body: Data) throws -> URLRequest {
        let url = try makeURL(path: path)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(Configuration.token)", forHTTPHeaderField: "Authorization")
        request.setValue("\(revision)", forHTTPHeaderField: "X-Last-Known-Revision")
        request.httpBody = body
        return request
    }

    private func makePutRequest(path: String, body: Data) throws -> URLRequest {
        let url = try makeURL(path: path)
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(Configuration.token)", forHTTPHeaderField: "Authorization")
        request.setValue("\(revision)", forHTTPHeaderField: "X-Last-Known-Revision")
        request.httpBody = body
        return request
    }

    private func makeDeleteRequest(path: String) throws -> URLRequest {
        let url = try makeURL(path: path)
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(Configuration.token)", forHTTPHeaderField: "Authorization")
        request.setValue("\(revision)", forHTTPHeaderField: "X-Last-Known-Revision")
        return request
    }

    private func performRequest(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        let (data, response) = try await urlSession.data(for: request)
        guard let response = response as? HTTPURLResponse else {
            throw RequestError.unexpectedResponse
        }
        try handleStatusCode(response: response)
        return (data, response)
    }

    private func handleStatusCode(response: HTTPURLResponse) throws {
        switch response.statusCode {
        case 100 ... 299:
            return
        case 400:
            throw RequestError.badRequest
        case 401:
            throw RequestError.wrongAuth
        case 404:
            throw RequestError.notFound
        case 500 ... 599:
            throw RequestError.serverError
        default:
            throw RequestError.unexpectedStatusCode(response.statusCode)
        }
    }

    private func mapData(todoItem: TodoItem) -> ElementDTO {
        return ElementDTO(
            id: todoItem.id.uuidString,
            text: todoItem.text,
            importance: todoItem.importance.rawValue,
            deadline: todoItem.deadline.map { Int($0.timeIntervalSince1970) },
            done: todoItem.isDone,
            color: todoItem.textColor,
            creationDate: Int(todoItem.creationDate.timeIntervalSince1970),
            modificationDate: Int((todoItem.modificationDate ?? todoItem.creationDate).timeIntervalSince1970),
            lastUpdatedBy: deviceID
        )
    }

    private func mapData(element: ElementDTO) -> TodoItem? {
        guard
            let id = UUID(uuidString: element.id),
            let importance = Importance(rawValue: element.importance),
            let textColor = element.color
        else {
            return nil
        }

        let creationDate = Date(timeIntervalSince1970: TimeInterval(element.creationDate))
        let deadline = element.deadline.map { Date(timeIntervalSince1970: TimeInterval($0)) }
        let modificationDate = Date(timeIntervalSince1970: TimeInterval(element.modificationDate))

        return TodoItem(
            id: id,
            text: element.text,
            importance: importance,
            deadline: deadline,
            isDone: element.done,
            creationDate: creationDate,
            modificationDate: modificationDate,
            textColor: textColor
        )
    }

}
