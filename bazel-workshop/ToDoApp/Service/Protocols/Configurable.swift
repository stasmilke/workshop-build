//
//  Configurable.swift
//  ToDoApp
//
//

import Foundation

@MainActor
protocol Configurable: AnyObject {
    associatedtype ConfigurationModel
    func configure(with model: ConfigurationModel)
}
