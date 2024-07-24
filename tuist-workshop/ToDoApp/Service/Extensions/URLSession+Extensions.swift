//
//  URLSession+Extensions.swift
//  ToDoApp
//
//

import Foundation

actor URLSessionDataTaskHolder {
    var task: URLSessionDataTask?
    var isCancelled: Bool = false

    func cancel() {
        isCancelled = true
        task?.cancel()
    }

    func set(_ dataTask: URLSessionDataTask) {
        task = dataTask
    }

    func isTaskCancelled() -> Bool {
        isCancelled
    }
}

extension URLSession {
    func dataTask(for urlRequest: URLRequest) async throws -> (Data, URLResponse) {
        let taskHolder = URLSessionDataTaskHolder()
        return try await withTaskCancellationHandler(operation: {
            try await withCheckedThrowingContinuation { continuation in
                Task {
                    let task = dataTask(with: urlRequest) { data, response, error in
                        if let data = data, let response = response, error == nil {
                            continuation.resume(returning: (data, response))
                        } else if let error = error {
                            continuation.resume(throwing: error)
                        } else {
                            continuation.resume(throwing: URLError(.badServerResponse))
                        }
                    }
                    await taskHolder.set(task)
                    let isCancelled = await taskHolder.isTaskCancelled()
                    if !isCancelled {
                        task.resume()
                    } else {
                        continuation.resume(throwing: CancellationError())
                    }
                }
            }
        }, onCancel: {
            Task {
                await taskHolder.cancel()
            }
        })
    }
}
