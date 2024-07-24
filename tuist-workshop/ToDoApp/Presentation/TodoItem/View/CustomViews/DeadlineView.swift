//
//  DeadlineView.swift
//  ToDoApp
//
//

import UIKit

final class DeadlineView: UIView {

    var switchChanged: ((Bool) -> Void)?
    var dateTapped: (() -> Void)?

    private lazy var deadlineLabel = UILabel()
    private lazy var selectedDateLabel = UILabel()
    private lazy var deadlineSwitch = UISwitch()

    override func draw(_ rect: CGRect) {
        setupDeadlineLabel()
        setupDateLabel()
        setupDeadlineSwitch()
        addDateLabelTapGestureRecognizer()
    }

    func setSwitchValue(_ value: Bool) {
        deadlineSwitch.isOn = value
    }

    func getSwitchValue() -> Bool {
        deadlineSwitch.isOn
    }

    func setSelectedDate(_ date: String?) {
        selectedDateLabel.text = date
    }

    func showDateInDateLabel(date: String) {
        UIView.animate(withDuration: 0.25) {
            self.selectedDateLabel.text = date
            self.layoutIfNeeded()
        }
    }

    func hideDateInDateLabel() {
        UIView.animate(withDuration: 0.25) {
            self.selectedDateLabel.text = nil
            self.layoutIfNeeded()
        }
    }

    private func setupDeadlineLabel() {
        deadlineLabel.text = L10n.toDoByLabelText
        deadlineLabel.font = .systemFont(ofSize: Constants.fontSize, weight: .regular)
        deadlineLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(deadlineLabel)

        NSLayoutConstraint.activate([
            deadlineLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: Constants.margin),
            deadlineLabel.centerYAnchor.constraint(lessThanOrEqualTo: self.centerYAnchor)
        ])
    }

    private func setupDateLabel() {
        selectedDateLabel.textColor = UIColor(named: "Blue")
        selectedDateLabel.font = .systemFont(ofSize: Constants.smallFontSize, weight: .semibold)
        selectedDateLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(selectedDateLabel)

        NSLayoutConstraint.activate([
            selectedDateLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: Constants.margin),
            selectedDateLabel.topAnchor.constraint(equalTo: deadlineLabel.bottomAnchor),
            selectedDateLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -Constants.smallMargin)
        ])
    }

    private func setupDeadlineSwitch() {
        deadlineSwitch.translatesAutoresizingMaskIntoConstraints = false
        deadlineSwitch.addAction(
            UIAction(handler: { [weak self] _ in
                if let switchChanged = self?.switchChanged,
                   let value = self?.deadlineSwitch.isOn {
                    switchChanged(value)
                }
            }),
            for: .valueChanged
        )
        self.addSubview(deadlineSwitch)

        NSLayoutConstraint.activate([
            deadlineSwitch.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -Constants.mediumMargin),
            deadlineSwitch.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }

    private func addDateLabelTapGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dateLabelTapped))
        selectedDateLabel.isUserInteractionEnabled = true
        selectedDateLabel.addGestureRecognizer(tapGestureRecognizer)
    }

    @objc private func dateLabelTapped() {
        if let dateTapped = dateTapped {
            dateTapped()
        }
    }

}

extension DeadlineView {
    private struct Constants {
        static let margin: CGFloat = 16
        static let mediumMargin: CGFloat = 12
        static let smallMargin: CGFloat = 9
        static let fontSize: CGFloat = 17
        static let smallFontSize: CGFloat = 13
    }
}
