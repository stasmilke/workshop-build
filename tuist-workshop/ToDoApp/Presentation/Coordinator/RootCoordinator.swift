//
//  RootCoordinator.swift
//  ToDoApp
//
//

import Foundation
import UIKit

@MainActor
protocol RootCoordinator: AnyObject {
    func start(in window: UIWindow)
}
