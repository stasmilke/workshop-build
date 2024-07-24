import UIKit
import CocoaLumberjackSwift

final class TodoListViewController: UIViewController {

    enum Section: Hashable {
        case main
    }

    enum Item: Hashable {
        case todoItem(TodoItemTableViewCell.DisplayData)
        case createNew
    }

    // MARK: - Private Properties

    private lazy var tableView = UITableView(frame: .zero, style: .insetGrouped)
    private lazy var dataSource = TodoListDataSource(tableView, viewOutput: viewOutput)
    private lazy var plusButton = UIButton()
    private lazy var completedLabel = UILabel()
    private lazy var completedAreShownButton = UIButton(type: .system)
    private lazy var headerView = UIView()
    private lazy var activityIndicator = UIActivityIndicatorView()

    private var viewOutput: TodoListViewOutput
    private var animator: Animator

    // MARK: - Life Cycle

    init(viewOutput: TodoListViewOutput, animator: Animator) {
        self.viewOutput = viewOutput
        self.animator = animator
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "BackPrimary")

        setupNavigationBar()
        setupHeaderView()
        setupTableView()
        setupPlusButton()
        updateDataSource(data: [])
        bindViewModel()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewOutput.loadData()
    }

    // MARK: - UI Setup

    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.layoutMargins.left = Constants.titleMargin
        navigationItem.title = L10n.listScreenTitle
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicator)
    }

    private func setupHeaderView() {
        headerView.isHidden = true
        completedLabel.textColor = UIColor(named: "LabelTertiary")
        completedLabel.font = .systemFont(ofSize: Constants.fontSize)
        completedLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(completedLabel)

        completedAreShownButton.addAction(
            UIAction(handler: { [weak self] _ in
                self?.toggleCompletedAreShownButton()
            }),
            for: .touchUpInside
        )
        completedAreShownButton.setTitle(L10n.showButton, for: .normal)
        completedAreShownButton.titleLabel?.font = .boldSystemFont(ofSize: Constants.fontSize)
        completedAreShownButton.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(completedAreShownButton)

        NSLayoutConstraint.activate([
            completedLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            completedLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: Constants.margin),
            completedAreShownButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            completedAreShownButton.trailingAnchor.constraint(
                equalTo: headerView.trailingAnchor,
                constant: -Constants.margin
            ),
            headerView.heightAnchor.constraint(equalToConstant: Constants.headerHeight)
        ])
    }

    private func setupTableView() {
        tableView.backgroundColor = nil
        tableView.estimatedRowHeight = Constants.estimatedRowHeight
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorInset = UIEdgeInsets(top: 0, left: Constants.leftInset, bottom: 0, right: 0)
        tableView.register(TodoItemTableViewCell.self, forCellReuseIdentifier: TodoItemTableViewCell.reuseIdentifier)
        tableView.register(CreateNewTableViewCell.self, forCellReuseIdentifier: CreateNewTableViewCell.reuseIdentifier)
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor)
        ])
    }

    private func setupPlusButton() {
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold, scale: .large)
        let plusImage = UIImage(systemName: "plus", withConfiguration: imageConfig)?
            .withTintColor(.white, renderingMode: .alwaysOriginal)
        plusButton.setImage(plusImage, for: .normal)
        plusButton.backgroundColor = .systemBlue
        plusButton.layer.cornerRadius = Constants.buttonSize / 2
        plusButton.layer.shadowColor = UIColor(named: "Shadow")?.cgColor
        plusButton.layer.shadowRadius = Constants.shadowRadius
        plusButton.layer.shadowOpacity = 1
        plusButton.layer.shadowOffset = CGSize(width: 0, height: Constants.shadowOffsetY)
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(plusButton)

        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            plusButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            plusButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -Constants.bottomMargin),
            plusButton.widthAnchor.constraint(equalToConstant: Constants.buttonSize),
            plusButton.heightAnchor.constraint(equalToConstant: Constants.buttonSize)
        ])

        plusButton.addAction(
            UIAction(handler: { [weak self] _ in self?.viewOutput.didTapAdd() }),
            for: .touchUpInside
        )
    }

    // MARK: - Tools

    private func bindViewModel() {
        viewOutput.todoListUpdated = { [weak self] todoList in
            self?.headerView.isHidden = false
            self?.updateDataSource(data: todoList, animated: true)
        }
        viewOutput.completedItemsCountUpdated = { [weak self] completedItemsCount in
            self?.updateCompletedItemsCount(newValue: completedItemsCount)
        }
        viewOutput.errorOccurred = { [weak self] description in
            self?.presentAlert(title: L10n.errorAlertTitle, message: description)
        }
        viewOutput.updateActivityIndicatorState = { [weak self] isActive in
            if isActive {
                self?.activityIndicator.startAnimating()
            } else {
                self?.activityIndicator.stopAnimating()
            }
        }
    }

    private func updateCompletedItemsCount(newValue: Int) {
        completedLabel.text = L10n.completed + String(newValue)
    }

    private func updateDataSource(data: [TodoItemTableViewCell.DisplayData], animated: Bool = false) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.main])
        snapshot.appendItems(data.map({ Item.todoItem($0) }))
        snapshot.appendItems([Item.createNew])
        dataSource.apply(snapshot, animatingDifferences: animated)
    }

    private func toggleCompletedAreShownButton() {
        if completedAreShownButton.currentTitle == L10n.showButton {
            viewOutput.changedCompletedAreShownValue(newValue: true)
            completedAreShownButton.setTitle(L10n.hideButton, for: .normal)
        } else if completedAreShownButton.currentTitle == L10n.hideButton {
            viewOutput.changedCompletedAreShownValue(newValue: false)
            completedAreShownButton.setTitle(L10n.showButton, for: .normal)
        }
    }

}

// MARK: - UITableViewDelegate

extension TodoListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if indexPath.row == tableView.numberOfRows(inSection: 0) - 1 {
            guard tableView.cellForRow(at: indexPath) is CreateNewTableViewCell else { return }
            viewOutput.didTapAdd()
            return
        }

        guard let cell = tableView.cellForRow(at: indexPath) as? TodoItemTableViewCell,
              let displayedItemID = cell.displayedItemID
        else { return }
        viewOutput.didSelectItem(with: displayedItemID)
    }

    func tableView(
        _ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        guard indexPath.row != tableView.numberOfRows(inSection: 0) - 1 else { return nil }

        let doneAction = UIContextualAction(style: .normal, title: nil) { [weak self] _, _, completion in
            guard
                let cell = tableView.cellForRow(at: indexPath) as? TodoItemTableViewCell,
                let displayedItemID = cell.displayedItemID
            else {
                return
            }
            self?.viewOutput.toggleIsDoneValue(for: displayedItemID)
            completion(true)
        }
        doneAction.image = UIImage(
            systemName: "checkmark.circle.fill",
            withConfiguration: UIImage.SymbolConfiguration(weight: .bold)
        )
        doneAction.backgroundColor = UIColor(named: "Green")
        return UISwipeActionsConfiguration(actions: [doneAction])
    }

    func tableView(
        _ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        guard indexPath.row != tableView.numberOfRows(inSection: 0) - 1 else { return nil }

        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] _, _, completion in
            guard
                let cell = tableView.cellForRow(at: indexPath) as? TodoItemTableViewCell,
                let displayedItemID = cell.displayedItemID
            else {
                return
            }
            self?.viewOutput.deleteItem(with: displayedItemID)
            completion(true)
        }
        deleteAction.image = UIImage(
            systemName: "trash.fill",
            withConfiguration: UIImage.SymbolConfiguration(weight: .bold)
        )
        let infoAction = UIContextualAction(style: .normal, title: nil) { [weak self] _, _, completion in
            guard
                let cell = tableView.cellForRow(at: indexPath) as? TodoItemTableViewCell,
                let displayedItemID = cell.displayedItemID
            else {
                return
            }
            self?.viewOutput.didSelectItem(with: displayedItemID)
            completion(true)
        }
        infoAction.image = UIImage(
            systemName: "info.circle.fill",
            withConfiguration: UIImage.SymbolConfiguration(weight: .bold)
        )
        return UISwipeActionsConfiguration(actions: [deleteAction, infoAction])
    }

    func tableView(
        _ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint
    ) -> UIContextMenuConfiguration? {
        guard indexPath.row != tableView.numberOfRows(inSection: 0) - 1 else { return nil }

        let doneAction = UIAction(title: L10n.done, image: UIImage(systemName: "checkmark")) { [weak self] _ in
            guard
                let cell = tableView.cellForRow(at: indexPath) as? TodoItemTableViewCell,
                let displayedItemID = cell.displayedItemID
            else {
                return
            }
            self?.viewOutput.toggleIsDoneValue(for: displayedItemID)
        }
        doneAction.image = UIImage(
            systemName: "checkmark",
            withConfiguration: UIImage.SymbolConfiguration(weight: .semibold)
        )

        let infoAction = UIAction(title: L10n.info) { [weak self] _ in
            guard
                let cell = tableView.cellForRow(at: indexPath) as? TodoItemTableViewCell,
                let displayedItemID = cell.displayedItemID
            else {
                return
            }
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
            self?.viewOutput.didSelectItem(with: displayedItemID)
        }
        infoAction.image = UIImage(
            systemName: "info",
            withConfiguration: UIImage.SymbolConfiguration(weight: .semibold)
        )

        let deleteAction = UIAction(
            title: L10n.delete,
            image: UIImage(systemName: "trash"),
            attributes: [.destructive]
        ) { [weak self] _ in
            guard
                let cell = tableView.cellForRow(at: indexPath) as? TodoItemTableViewCell,
                let displayedItemID = cell.displayedItemID
            else {
                return
            }
            self?.viewOutput.deleteItem(with: displayedItemID)
        }
        deleteAction.image = UIImage(
            systemName: "trash",
            withConfiguration: UIImage.SymbolConfiguration(weight: .semibold)
        )

        return UIContextMenuConfiguration(identifier: indexPath as NSIndexPath, previewProvider: nil) { _ in
            UIMenu(title: L10n.actions, children: [doneAction, infoAction, deleteAction])
        }
    }

    func tableView(
        _ tableView: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration,
        animator: UIContextMenuInteractionCommitAnimating
    ) {
        guard let indexPath = configuration.identifier as? IndexPath else { return }
        guard
            let cell = tableView.cellForRow(at: indexPath) as? TodoItemTableViewCell,
            let displayedItemID = cell.displayedItemID
        else {
            return
        }
        tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        viewOutput.didSelectItem(with: displayedItemID)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Constants.headerHeight
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return headerView
    }

}

// MARK: - UIViewControllerTransitioningDelegate

extension TodoListViewController: UIViewControllerTransitioningDelegate {
    func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        guard
            let selectedIndexPathCell = tableView.indexPathForSelectedRow,
            let selectedCell = tableView.cellForRow(at: selectedIndexPathCell) as? TodoItemTableViewCell
                ?? tableView.cellForRow(at: selectedIndexPathCell) as? CreateNewTableViewCell,
            let selectedCellSuperview = selectedCell.superview
        else {
            return nil
        }
        tableView.deselectRow(at: selectedIndexPathCell, animated: true)
        animator.originFrame = selectedCellSuperview.convert(selectedCell.frame, to: nil)
        animator.originFrame = CGRect(
            x: animator.originFrame.origin.x + 20,
            y: animator.originFrame.origin.y + 20,
            width: animator.originFrame.size.width - 40,
            height: animator.originFrame.size.height - 40
        )

        return animator
    }
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return nil
    }
}

// MARK: - Constants

extension TodoListViewController {
    private struct Constants {
        static let margin: CGFloat = 16
        static let titleMargin: CGFloat = 32
        static let bottomMargin: CGFloat = 20
        static let buttonSize: CGFloat = 44
        static let shadowRadius: CGFloat = 10
        static let shadowOffsetY: CGFloat = 8
        static let leftInset: CGFloat = 52
        static let cornerRadius: CGFloat = 16
        static let headerHeight: CGFloat = 40
        static let fontSize: CGFloat = 15
        static let estimatedRowHeight: CGFloat = 56
    }
}
