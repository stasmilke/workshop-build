//
//  TodoListDataSource.swift
//  ToDoApp
//
//

import Foundation
import UIKit

final class TodoListDataSource:
    UITableViewDiffableDataSource<TodoListViewController.Section, TodoListViewController.Item> {

    init(_ tableView: UITableView, viewOutput: TodoListViewOutput) {
        super.init(tableView: tableView) { tableView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .todoItem(let displayData):
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: TodoItemTableViewCell.reuseIdentifier,
                    for: indexPath
                ) as? TodoItemTableViewCell
                else {
                    return UITableViewCell()
                }
                cell.accessoryType = .disclosureIndicator
                cell.checkmarkCallback = { displayedItemID in
                    viewOutput.toggleIsDoneValue(for: displayedItemID)
                }
                cell.configure(with: displayData)
                return cell
            case .createNew:
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: CreateNewTableViewCell.reuseIdentifier,
                    for: indexPath
                ) as? CreateNewTableViewCell
                else {
                    return UITableViewCell()
                }
                return cell
            }
        }
    }

}
