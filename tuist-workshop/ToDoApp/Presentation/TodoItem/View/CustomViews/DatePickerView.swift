//
//  DatePickerView.swift
//  ToDoApp
//
//

import UIKit

final class DatePickerView: UIView {

    var dateChanged: ((Date) -> Void)?

    private lazy var datePicker = UIDatePicker()
    private lazy var separator = UIView()

    override func draw(_ rect: CGRect) {
        setupDatePicker()
        setupSeparator()
    }

    func getDate() -> Date {
        datePicker.date
    }

    func setDate(_ date: Date) {
        datePicker.date = date
    }

    func setMinimumDate(_ date: Date) {
        datePicker.minimumDate = date
    }

    private func setupDatePicker() {
        datePicker.locale = Locale(identifier: "ru")
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .inline
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(datePicker)

        NSLayoutConstraint.activate([
            datePicker.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: Constants.smallMargin),
            datePicker.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -Constants.smallMargin),
            datePicker.topAnchor.constraint(equalTo: self.topAnchor, constant: Constants.smallMargin),
            datePicker.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -Constants.smallMargin)
        ])

        datePicker.addAction(
            UIAction(handler: { [weak self] _ in
                if let dateChanged = self?.dateChanged,
                   let date = self?.datePicker.date {
                    dateChanged(date)
                }
            }),
            for: .valueChanged
        )
    }

    private func setupSeparator() {
        separator.backgroundColor = UIColor(named: "Separator")
        separator.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(separator)

        NSLayoutConstraint.activate([
            separator.heightAnchor.constraint(equalToConstant: Constants.separatorHeight),
            separator.topAnchor.constraint(equalTo: self.topAnchor),
            separator.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: Constants.margin),
            separator.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -Constants.margin)
        ])
    }

}

extension DatePickerView {
    private struct Constants {
        static let margin: CGFloat = 16
        static let smallMargin: CGFloat = 9
        @MainActor static let separatorHeight: CGFloat = 1 / UIScreen.main.scale
    }
}
