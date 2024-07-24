//
//  TodoListViewOutput.swift
//  ToDoApp
//
//

import Foundation

@MainActor
protocol TodoListViewOutput {
    var completedItemsCountUpdated: ((Int) -> Void)? { get set }
    var todoListUpdated: (([TodoItemTableViewCell.DisplayData]) -> Void)? { get set }
    var updateActivityIndicatorState: ((Bool) -> Void)? { get set }
    var errorOccurred: ((String) -> Void)? { get set }
    func loadData()
    func changedCompletedAreShownValue(newValue: Bool)
    func didTapAdd()
    func deleteItem(with: UUID)
    func didSelectItem(with: UUID)
    func toggleIsDoneValue(for: UUID)
}
