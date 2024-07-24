//
//  RootCoordinatorImpl.swift
//  ToDoApp
//
//

import Foundation
import UIKit

final class RootCoordinatorImpl: RootCoordinator {

    private weak var window: UIWindow?
    private weak var transitioningDelegate: UIViewControllerTransitioningDelegate?
    private weak var todoItemViewModelDelegate: TodoItemViewModelDelegate?
    private lazy var fileCache: FileCache = FileCacheImpl()
    private lazy var dateService: DateService = DateServiceImpl()
    private lazy var cacheService: CacheService = CoreDataCacheServiceImpl()
    private lazy var networkService: NetworkService = NetworkServiceImpl(
        deviceID: UIDevice.current.identifierForVendor?.uuidString ?? ""
    )

    func start(in window: UIWindow) {
        self.window = window
        openTodoList()
    }

    // MARK: - Navigation

    private func openTodoList() {
        let viewModel = TodoListViewModel(
            networkService: networkService,
            dateService: dateService,
            cacheService: cacheService,
            coordinator: self
        )
        todoItemViewModelDelegate = viewModel
        let animator = Animator()
        let viewController = TodoListViewController(viewOutput: viewModel, animator: animator)
        transitioningDelegate = viewController
        let navigationController = UINavigationController(rootViewController: viewController)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }

    private func openTodoItem(_ item: TodoItem?, delegate: TodoItemViewModelDelegate?) {
        let viewModel = TodoItemViewModel(todoItem: item, coordinator: self)
        viewModel.delegate = todoItemViewModelDelegate
        let viewController = TodoItemViewController(viewOutput: viewModel, dateService: dateService)
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.transitioningDelegate = transitioningDelegate
        window?.rootViewController?.dismiss(animated: true)
        window?.rootViewController?.present(navigationController, animated: true)
    }

    private func closeTodoItem() {
        window?.rootViewController?.dismiss(animated: true)
    }

}

// MARK: - TodoListCoordinator

extension RootCoordinatorImpl: TodoListCoordinator {

    func openDetails(of item: TodoItem, delegate: TodoItemViewModelDelegate?) {
        openTodoItem(item, delegate: delegate)
    }

    func openCreationOfTodoItem(delegate: TodoItemViewModelDelegate?) {
        openTodoItem(nil, delegate: delegate)
    }

}

// MARK: - TodoItemCoordinator

extension RootCoordinatorImpl: TodoItemCoordinator {

    func closeDetails() {
        closeTodoItem()
    }

}
