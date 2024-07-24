//
//  ImportanceView.swift
//  ToDoApp
//
//

import UIKit

final class ImportanceView: UIView {

    private lazy var importanceLabel = UILabel()
    private lazy var importanceControl = UISegmentedControl()
    private lazy var separator = UIView()
    private var selectedIndex = 1

    override func draw(_ rect: CGRect) {
        setupImportanceLabel()
        setupImportanceControl()
        setupSeparator()
    }

    func getSelectedIndex() -> Int {
        importanceControl.selectedSegmentIndex
    }

    func setSelectedIndex(_ index: Int) {
        selectedIndex = index
    }

    private func setupImportanceLabel() {
        importanceLabel.text = L10n.importanceLabelText
        importanceLabel.font = .systemFont(ofSize: Constants.fontSize, weight: .regular)
        importanceLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(importanceLabel)

        NSLayoutConstraint.activate([
            importanceLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: Constants.margin),
            importanceLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }

    private func setupImportanceControl() {
        let scaleConfig = UIImage.SymbolConfiguration(scale: .small)
        let weightConfig = UIImage.SymbolConfiguration(weight: .bold)
        let arrowImage = UIImage(
            systemName: "arrow.down",
            withConfiguration: scaleConfig.applying(weightConfig)
        )?.withTintColor(UIColor(named: "Gray") ?? .gray, renderingMode: .alwaysOriginal)
        let exclamationmarkImage = UIImage(
            systemName: "exclamationmark.2",
            withConfiguration: scaleConfig.applying(weightConfig)
        )?.withTintColor(UIColor(named: "Red") ?? .red, renderingMode: .alwaysOriginal)

        importanceControl.insertSegment(with: arrowImage, at: 0, animated: true)
        importanceControl.insertSegment(withTitle: L10n.regularImportanceChoice, at: 1, animated: true)
        importanceControl.insertSegment(with: exclamationmarkImage, at: 2, animated: true)
        importanceControl.selectedSegmentIndex = selectedIndex

        importanceControl.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(importanceControl)

        NSLayoutConstraint.activate([
            importanceControl.trailingAnchor.constraint(
                equalTo: self.trailingAnchor,
                constant: -Constants.mediumMargin
            ),
            importanceControl.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }

    private func setupSeparator() {
        separator.backgroundColor = UIColor(named: "Separator")
        separator.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(separator)

        NSLayoutConstraint.activate([
            separator.heightAnchor.constraint(equalToConstant: Constants.separatorHeight),
            separator.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            separator.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: Constants.margin),
            separator.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -Constants.margin)
        ])
    }

}

extension ImportanceView {
    private struct Constants {
        static let margin: CGFloat = 16
        static let mediumMargin: CGFloat = 12
        static let fontSize: CGFloat = 17
        @MainActor static let separatorHeight: CGFloat = 1 / UIScreen.main.scale
    }
}
