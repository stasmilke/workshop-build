//
//  TodoItemViewModel.swift
//  ToDoApp
//
//

import Foundation

@MainActor
final class TodoItemViewModel: TodoItemViewOutput {

    var todoItemLoaded: ((TodoItem) -> Void)?
    var changesSaved: (() -> Void)?
    weak var delegate: TodoItemViewModelDelegate?

    private var todoItem: TodoItem?
    private weak var coordinator: TodoItemCoordinator?

    init(todoItem: TodoItem?, coordinator: TodoItemCoordinator?) {
        self.todoItem = todoItem
        self.coordinator = coordinator
    }

    // MARK: - Public Methods

    func loadItemIfExist() {
        if let item = todoItem,
           let todoItemLoaded = todoItemLoaded {
            todoItemLoaded(item)
        }
    }

    func saveItem(text: String, importance: Importance, deadline: Date?, textColor: String) {
        let newItem = getTodoItem(text: text, importance: importance, deadline: deadline, textColor: textColor)
        let isNewItem = todoItem == nil

        delegate?.saveToCacheTodoItem(newItem)
        if let changesSaved = changesSaved {
            changesSaved()
        }
        delegate?.saveToServerTodoItem(newItem, isNewItem: isNewItem)

        todoItem = newItem
    }

    func deleteItem() {
        guard let id = todoItem?.id else { return }

        delegate?.deleteFromCacheTodoItem(with: id)
        if let changesSaved = changesSaved {
            changesSaved()
        }

        delegate?.deleteFromServerTodoItem(with: id)
    }

    func close() {
        coordinator?.closeDetails()
    }

    // MARK: - Private Methods

    private func getTodoItem(text: String, importance: Importance, deadline: Date?, textColor: String) -> TodoItem {
        if let currentTodoItem = todoItem {
            let newItem = TodoItem(
                id: currentTodoItem.id,
                text: text,
                importance: importance,
                deadline: deadline,
                isDone: currentTodoItem.isDone,
                creationDate: currentTodoItem.creationDate,
                modificationDate: Date(),
                textColor: textColor
            )
            return newItem
        } else {
            return TodoItem(text: text, importance: importance, deadline: deadline, textColor: textColor)
        }
    }

}
