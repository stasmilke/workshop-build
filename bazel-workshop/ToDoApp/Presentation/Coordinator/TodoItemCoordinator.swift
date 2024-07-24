//
//  TodoItemCoordinator.swift
//  ToDoApp
//
//

import Foundation

@MainActor
protocol TodoItemCoordinator: AnyObject {
    func closeDetails()
}
