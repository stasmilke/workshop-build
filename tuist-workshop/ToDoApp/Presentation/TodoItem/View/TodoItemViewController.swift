import UIKit
import CocoaLumberjackSwift

final class TodoItemViewController: UIViewController {

    // MARK: - Private Properties

    private lazy var scrollView = UIScrollView()
    private lazy var textView = UITextView()
    private lazy var importanceView = ImportanceView()
    private lazy var colorView = ColorView()
    private lazy var colorPickerView = ColorPickerView()
    private lazy var deadlineView = DeadlineView()
    private lazy var datePickerView = DatePickerView()
    private lazy var detailsStackView = UIStackView()
    private lazy var deleteButton = UIButton()

    private var viewOutput: TodoItemViewOutput
    private var dateService: DateService

    // MARK: - Life Cycle

    init(viewOutput: TodoItemViewOutput, dateService: DateService) {
        self.viewOutput = viewOutput
        self.dateService = dateService
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "BackPrimary")

        setupNavigationItem()
        setupScrollView()
        setupTextView()
        setupImportanceView()
        setupColorView()
        setupColorPickerView()
        setupDeadlineView()
        setupDatePickerView()
        setupDetailsStackView()
        setupDeleteButton()
        registerKeyboardNotifications()
        addTapGestureRecognizerToDismissKeyboard()

        bindViewModel()
        viewOutput.loadItemIfExist()
    }

    // MARK: - UI Setup

    private func setupNavigationItem() {
        navigationItem.title = L10n.todoScreenTitle
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: L10n.cancelButtonTitle, style: .plain,
            target: self, action: #selector(didTapCancelButton)
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: L10n.saveButtonTitle, style: .done,
            target: self, action: #selector(didTapSaveButton)
        )
    }

    private func setupScrollView() {
        scrollView.contentSize = view.bounds.size
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupTextView() {
        textView.delegate = self
        textView.isScrollEnabled = false
        textView.backgroundColor = UIColor(named: "BackSecondary")
        textView.layer.cornerRadius = Constants.cornerRadius
        textView.font = .systemFont(ofSize: Constants.fontSize, weight: .regular)
        textView.text = L10n.todoTextPlaceholder
        textView.textColor = UIColor(named: "LabelTertiary")
        textView.textContainerInset = UIEdgeInsets(
            top: Constants.margin, left: Constants.margin,
            bottom: Constants.mediumMargin, right: Constants.margin
        )
        textView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(textView)

        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: Constants.margin),
            textView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -Constants.margin),
            textView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: Constants.margin),
            textView.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.bigHeight)
        ])
    }

    private func setupImportanceView() {
        importanceView.heightAnchor.constraint(
            equalToConstant: Constants.defaultHeight + Constants.separatorHeight
        ).isActive = true
    }

    private func setupColorView() {
        colorView.paletteButtonTapped = { [weak self] in
            self?.toggleColorPickerVisibility()
        }
        colorView.setText(UIColor.red.hex)
        colorView.setTextColor(UIColor.red)
        colorView.heightAnchor.constraint(
            equalToConstant: Constants.defaultHeight + Constants.separatorHeight
        ).isActive = true
    }

    private func setupColorPickerView() {
        colorPickerView.colorChanged = { [weak self] color in
            self?.changeColorOfText(color: color)
            self?.colorView.setText(color.hex)
        }
        colorPickerView.heightAnchor.constraint(
            equalToConstant: Constants.bigHeight + Constants.separatorHeight
        ).isActive = true
    }

    private func setupDeadlineView() {
        deadlineView.dateTapped = { [weak self] in
            self?.toggleDateViewVisibility()
        }
        deadlineView.switchChanged = { [weak self] value in
            if value {
                if let stringDate = self?.dateService.getString(from: self?.datePickerView.getDate()) {
                    self?.deadlineView.showDateInDateLabel(date: stringDate)
                }
            } else {
                self?.deadlineView.hideDateInDateLabel()
                if self?.datePickerView.superview != nil {
                    self?.hideDateView()
                }
            }
        }
        deadlineView.heightAnchor.constraint(equalToConstant: Constants.defaultHeight).isActive = true
    }

    private func setupDatePickerView() {
        datePickerView.dateChanged = { [weak self] date in
            self?.deadlineView.setSelectedDate(self?.dateService.getString(from: date))
        }
        datePickerView.setDate(dateService.getNextDay() ?? Date())
        datePickerView.setMinimumDate(Date())
        datePickerView.heightAnchor.constraint(equalToConstant: Constants.datePickerHeight).isActive = true
    }

    private func setupDetailsStackView() {
        detailsStackView.axis = .vertical
        detailsStackView.backgroundColor = UIColor(named: "BackSecondary")
        detailsStackView.layer.cornerRadius = Constants.cornerRadius
        detailsStackView.addArrangedSubview(importanceView)
        detailsStackView.addArrangedSubview(colorView)
        detailsStackView.addArrangedSubview(deadlineView)
        detailsStackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(detailsStackView)

        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            detailsStackView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: Constants.margin),
            detailsStackView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -Constants.margin),
            detailsStackView.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: Constants.margin)
        ])
    }

    private func setupDeleteButton() {
        deleteButton.isEnabled = false
        deleteButton.backgroundColor = UIColor(named: "BackSecondary")
        deleteButton.layer.cornerRadius = Constants.cornerRadius
        deleteButton.titleLabel?.font = .systemFont(ofSize: Constants.fontSize, weight: .regular)
        deleteButton.setTitle(L10n.deleteButtonTitle, for: .normal)
        deleteButton.setTitleColor(UIColor(named: "Red"), for: .normal)
        deleteButton.setTitleColor(UIColor(named: "LabelTertiary"), for: .disabled)
        deleteButton.addAction(
            UIAction(handler: { [weak self] _ in
                self?.viewOutput.deleteItem()
            }),
            for: .touchUpInside
        )
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(deleteButton)

        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            deleteButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: Constants.margin),
            deleteButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -Constants.margin),
            deleteButton.topAnchor.constraint(equalTo: detailsStackView.bottomAnchor, constant: Constants.margin),
            deleteButton.heightAnchor.constraint(equalToConstant: Constants.defaultHeight),
            deleteButton.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -Constants.margin)
        ])
    }

    // MARK: - Actions

    @objc private func didTapCancelButton() {
        viewOutput.close()
    }

    @objc private func didTapSaveButton() {
        dismissKeyboard()
        guard let text = textView.textColor == UIColor(named: "LabelTertiary") ? nil : textView.text
        else {
            self.presentAlert(title: L10n.textIsEmpty)
            return
        }
        let importance = Importance.getValue(index: importanceView.getSelectedIndex())
        let deadline = deadlineView.getSwitchValue() ? datePickerView.getDate() : nil
        let textColor = colorView.getTextColor()
        viewOutput.saveItem(text: text, importance: importance, deadline: deadline, textColor: textColor.hex)
    }

    @objc private func keyboardWillShow(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        else { return }
        let keyboardHeight = keyboardFrame.height
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }

    @objc private func keyboardWillHide() {
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }

    @objc private func dismissKeyboard() {
        textView.endEditing(true)
    }

}

// MARK: - Tools

extension TodoItemViewController {
    private func toggleColorPickerVisibility() {
        if colorPickerView.superview != nil {
            hideColorPickerView()
        } else {
            showColorPickerView()
        }
    }

    private func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification, object: nil
        )
    }

    private func addTapGestureRecognizerToDismissKeyboard() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGestureRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGestureRecognizer)
    }

    private func bindViewModel() {
        viewOutput.todoItemLoaded = { [weak self] todoItem in
            self?.updateText(text: todoItem.text)
            self?.importanceView.setSelectedIndex(todoItem.importance.index)
            if let deadline = todoItem.deadline {
                self?.updateDeadline(deadline: deadline)
            }
            let color = UIColor.convertHexToUIColor(hex: todoItem.textColor)
            self?.changeColorOfText(color: color)
            self?.colorView.setText(todoItem.textColor)
            self?.deleteButton.isEnabled = true
        }
        viewOutput.changesSaved = { [weak self] in
            self?.viewOutput.close()
        }
    }

    private func updateText(text: String) {
        if !text.isEmpty {
            textView.text = text
            textView.textColor = colorView.getTextColor()
        } else {
            textView.text = L10n.todoTextPlaceholder
            textView.textColor = UIColor(named: "LabelTertiary")
        }
    }

    private func updateDeadline(deadline: Date) {
        deadlineView.setSelectedDate(dateService.getString(from: deadline))
        deadlineView.setSwitchValue(true)
        datePickerView.setDate(deadline)
        datePickerView.setMinimumDate(deadline < Date() ? deadline : Date())
    }

    private func toggleDateViewVisibility() {
        if datePickerView.superview == nil {
            showDateView()
        } else {
            hideDateView()
        }
    }

    private func changeColorOfText(color: UIColor) {
        if textView.textColor != UIColor(named: "LabelTertiary") {
            textView.textColor = color
        }
        colorView.setTextColor(color)
    }

    private func showDateView() {
        UIView.animate(withDuration: 0.5) {
            self.detailsStackView.addArrangedSubview(self.datePickerView)
            self.view.layoutIfNeeded()
        }
    }

    private func hideDateView() {
        UIView.animate(withDuration: 0.5) {
            self.datePickerView.removeFromSuperview()
            self.view.layoutIfNeeded()
        }
    }

    private func showColorPickerView() {
        UIView.animate(withDuration: 0.5) {
            self.detailsStackView.insertArrangedSubview(self.colorPickerView, at: 2)
            self.view.layoutIfNeeded()
        }
    }

    private func hideColorPickerView() {
        UIView.animate(withDuration: 0.5) {
            self.colorPickerView.removeFromSuperview()
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - UITextViewDelegate

extension TodoItemViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor(named: "LabelTertiary") {
            textView.text = nil
            textView.textColor = colorView.getTextColor()
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = L10n.todoTextPlaceholder
            textView.textColor = UIColor(named: "LabelTertiary")
        }
    }
}

// MARK: - Constants

extension TodoItemViewController {
    private struct Constants {
        static let margin: CGFloat = 16
        static let mediumMargin: CGFloat = 12
        static let defaultHeight: CGFloat = 56
        static let bigHeight: CGFloat = 120
        static let fontSize: CGFloat = 17
        static let cornerRadius: CGFloat = 16
        static let datePickerHeight: CGFloat = 312
        @MainActor static let separatorHeight: CGFloat = 1 / UIScreen.main.scale
    }
}
