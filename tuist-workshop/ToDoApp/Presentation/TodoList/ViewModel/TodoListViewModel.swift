//
//  TodoListViewModel.swift
//  ToDoApp
//
//

import Foundation
import CocoaLumberjackSwift

@MainActor
final class TodoListViewModel: TodoListViewOutput {

    var completedItemsCountUpdated: ((Int) -> Void)?
    var todoListUpdated: (([TodoItemTableViewCell.DisplayData]) -> Void)?
    var errorOccurred: ((String) -> Void)?
    var updateActivityIndicatorState: ((Bool) -> Void)?

    // MARK: - Private Properties

    private var completedAreShown: Bool = false
    private var completedItemsCount: Int = 0
    private var todoList: [TodoItem] = []

    private let networkService: NetworkService
    private let cacheService: CacheService
    private let dateService: DateService
    private weak var coordinator: TodoListCoordinator?

    init(
        networkService: NetworkService,
        dateService: DateService,
        cacheService: CacheService,
        coordinator: TodoListCoordinator
    ) {
        self.networkService = networkService
        self.dateService = dateService
        self.cacheService = cacheService
        self.coordinator = coordinator
    }

    // MARK: - Public Methods

    func loadData() {
        loadDataFromCache()
        sendData()

        handleActivityIndicator(by: true)
        networkService.incrementNumberOfTasks()
        if cacheService.isDirty {
            syncTodoList()
        } else {
            loadTodoList()
        }
    }

    func changedCompletedAreShownValue(newValue: Bool) {
        completedAreShown = newValue
        sendData()
    }

    func toggleIsDoneValue(for id: UUID) {
        guard let item = cacheService.todoItems[id] else { return }
        let newItem = getUpdatedItem(for: item, newIsDoneValue: !item.isDone)
        Task(priority: .userInitiated) {
            await upsertItemToCache(newItem)
            sendData()
        }

        handleActivityIndicator(by: true)
        networkService.incrementNumberOfTasks()
        if cacheService.isDirty {
            syncTodoList()
        } else {
            changeTodoItem(newItem)
        }
    }

    func deleteItem(with id: UUID) {
        Task(priority: .userInitiated) {
            await deleteFromCacheItem(with: id)
            sendData()
        }

        handleActivityIndicator(by: true)
        networkService.incrementNumberOfTasks()
        if cacheService.isDirty {
            syncTodoList()
        } else {
            deleteTodoItem(with: id)
        }
    }

    func didSelectItem(with id: UUID) {
        guard let item = cacheService.todoItems[id] else { return }
        coordinator?.openDetails(of: item, delegate: self)
    }

    func didTapAdd() {
        coordinator?.openCreationOfTodoItem(delegate: self)
    }

    // MARK: - Private Methods

    private func sendData() {
        var itemsToDisplay: [TodoItem] = []
        if completedAreShown {
            itemsToDisplay = todoList
        } else {
            itemsToDisplay = todoList.filter({ $0.isDone == false })
        }
        if let todoListLoaded = todoListUpdated {
            let displayData: [TodoItemTableViewCell.DisplayData] = mapData(items: itemsToDisplay)
            todoListLoaded(displayData)
        }
        if let completedItemsCountChanged = completedItemsCountUpdated {
            completedItemsCountChanged(completedItemsCount)
        }
    }

    private func updateData(with newList: [TodoItem]) {
        todoList = newList
        todoList.sort(by: { $0.creationDate > $1.creationDate })
        completedItemsCount = todoList.filter({ $0.isDone == true }).count
    }

    private func getUpdatedItem(for item: TodoItem, newIsDoneValue: Bool) -> TodoItem {
        TodoItem(
            id: item.id,
            text: item.text,
            importance: item.importance,
            deadline: item.deadline,
            isDone: newIsDoneValue,
            creationDate: item.creationDate,
            modificationDate: Date(),
            textColor: item.textColor
        )
    }

    private func mapData(items: [TodoItem]) -> [TodoItemTableViewCell.DisplayData] {
        items.map { item in
            TodoItemTableViewCell.DisplayData(
                id: item.id,
                text: item.text,
                importance: item.importance,
                deadline: dateService.getString(from: item.deadline),
                isDone: item.isDone
            )
        }
    }

    private func handleActivityIndicator(by state: Bool) {
        if networkService.numberOfTasks == 0,
           let updateActivityIndicatorState = updateActivityIndicatorState {
            updateActivityIndicatorState(state)
        }
    }

}

// MARK: - TodoItemViewModelDelegate

extension TodoListViewModel: TodoItemViewModelDelegate {

    func saveToCacheTodoItem(_ newItem: TodoItem) {
        Task(priority: .userInitiated) {
            await upsertItemToCache(newItem)
            sendData()
        }
    }

    func deleteFromCacheTodoItem(with id: UUID) {
        Task(priority: .userInitiated) {
            await deleteFromCacheItem(with: id)
            sendData()
        }
    }

    func saveToServerTodoItem(_ newItem: TodoItem, isNewItem: Bool) {
        handleActivityIndicator(by: true)
        networkService.incrementNumberOfTasks()
        if cacheService.isDirty {
            syncTodoList()
        } else if isNewItem {
            addTodoItem(newItem)
        } else {
            changeTodoItem(newItem)
        }
    }

    func deleteFromServerTodoItem(with id: UUID) {
        handleActivityIndicator(by: true)
        networkService.incrementNumberOfTasks()
        if cacheService.isDirty {
            syncTodoList()
        } else {
            deleteTodoItem(with: id)
        }
    }

}

// MARK: - Networking

extension TodoListViewModel {

    private func loadTodoList() {
        Task(priority: .userInitiated) { [weak self] in
            guard let self = self else { return }
            do {
                let todoList = try await self.networkService.loadTodoList()
                await self.updateCache(with: todoList)
                self.sendData()
            } catch {
                DDLogError("\(#function): \(error.localizedDescription)")
                if let errorOccurred = self.errorOccurred {
                    errorOccurred(error.localizedDescription)
                }
            }
            self.networkService.decrementNumberOfTasks()
            self.handleActivityIndicator(by: false)
        }
    }

    private func syncTodoList() {
        Task(priority: .userInitiated) { [weak self] in
            guard let self = self else { return }
            do {
                let todoList = try await self.networkService.syncTodoList(todoList)
                await self.updateCache(with: todoList)
                self.sendData()
                self.cacheService.updateIsDirtyValue(by: false)
            } catch {
                DDLogError("\(#function): \(error.localizedDescription)")
                if let errorOccurred = self.errorOccurred {
                    errorOccurred(error.localizedDescription)
                }
            }
            self.networkService.decrementNumberOfTasks()
            self.handleActivityIndicator(by: false)
        }
    }

    private func changeTodoItem(_ item: TodoItem, retryDelay: Int = Backoff.minDelay) {
        Task(priority: .userInitiated) { [weak self] in
            guard let self = self else { return }
            do {
                try await self.networkService.changeTodoItem(item)
                self.networkService.decrementNumberOfTasks()
                self.handleActivityIndicator(by: false)
            } catch {
                DDLogError("\(#function): \(error.localizedDescription)")
                if retryDelay < Backoff.maxDelay,
                   let requestError = error as? RequestError,
                   case .serverError = requestError {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(retryDelay)) {
                        self.changeTodoItem(item, retryDelay: Backoff.getNextDelay(from: retryDelay))
                    }
                } else {
                    self.cacheService.updateIsDirtyValue(by: true)
                    self.syncTodoList()
                }
            }
        }
    }

    private func addTodoItem(_ item: TodoItem, retryDelay: Int = Backoff.minDelay) {
        Task(priority: .userInitiated) { [weak self] in
            guard let self = self else { return }
            do {
                try await self.networkService.addTodoItem(item)
                self.networkService.decrementNumberOfTasks()
                self.handleActivityIndicator(by: false)
            } catch {
                DDLogError("\(#function): \(error.localizedDescription)")
                if retryDelay < Backoff.maxDelay,
                   let requestError = error as? RequestError,
                   case .serverError = requestError {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(retryDelay)) {
                        self.changeTodoItem(item, retryDelay: Backoff.getNextDelay(from: retryDelay))
                    }
                } else {
                    self.cacheService.updateIsDirtyValue(by: true)
                    self.syncTodoList()
                }
            }
        }
    }

    private func deleteTodoItem(with id: UUID, retryDelay: Int = Backoff.minDelay) {
        Task(priority: .userInitiated) { [weak self] in
            guard let self = self else { return }
            do {
                try await self.networkService.deleteTodoItem(id: id.uuidString)
                self.networkService.decrementNumberOfTasks()
                self.handleActivityIndicator(by: false)
            } catch {
                DDLogError("\(#function): \(error.localizedDescription)")
                if retryDelay < Backoff.maxDelay,
                   let requestError = error as? RequestError,
                   case .serverError = requestError {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(retryDelay)) {
                        self.deleteTodoItem(with: id, retryDelay: Backoff.getNextDelay(from: retryDelay))
                    }
                } else {
                    self.cacheService.updateIsDirtyValue(by: true)
                    self.syncTodoList()
                }
            }
        }
    }

}

// MARK: - Caching

extension TodoListViewModel {

    private func upsertItemToCache(_ item: TodoItem) async {
        do {
            try await cacheService.upsertTodoItem(item)
            updateData(with: Array(cacheService.todoItems.values))
        } catch {
            DDLogError("\(#function): \(error.localizedDescription)")
            if let errorOccurred = self.errorOccurred {
                errorOccurred(error.localizedDescription)
            }
        }
    }

    private func deleteFromCacheItem(with id: UUID) async {
        do {
            try await cacheService.deleteTodoItem(with: id)
            updateData(with: Array(cacheService.todoItems.values))
        } catch {
            DDLogError("\(#function): \(error.localizedDescription)")
            if let errorOccurred = self.errorOccurred {
                errorOccurred(error.localizedDescription)
            }
        }
    }

    private func updateCache(with todoList: [TodoItem]) async {
        do {
            try await cacheService.updateTodoList(with: todoList)
            updateData(with: todoList)
        } catch {
            DDLogError("\(#function): \(error.localizedDescription)")
            if let errorOccurred = self.errorOccurred {
                errorOccurred(error.localizedDescription)
            }
        }
    }

    private func loadDataFromCache() {
        do {
            let values = try cacheService.loadTodoList()
            updateData(with: values)
        } catch {
            DDLogError("\(#function): \(error.localizedDescription)")
            if let errorOccurred = self.errorOccurred {
                errorOccurred(error.localizedDescription)
            }
        }
    }

}
