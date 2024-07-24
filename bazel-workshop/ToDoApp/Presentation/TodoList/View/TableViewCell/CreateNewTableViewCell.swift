//
//  CreateNewTableViewCell.swift
//  ToDoApp
//
//

import UIKit

final class CreateNewTableViewCell: UITableViewCell {

    // MARK: - Private Properties

    private lazy var titleLabel = UILabel()

    // MARK: - Life Cycle

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor(named: "BackSecondary")

        setupTitleLabel()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI Setup

    private func setupTitleLabel() {
        titleLabel.text = L10n.new
        titleLabel.textColor = UIColor(named: "LabelTertiary")
        titleLabel.font = .systemFont(ofSize: Constants.fontSize, weight: .regular)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.leftMargin),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.margin),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.margin)
        ])
    }

}

// MARK: - Constants

extension CreateNewTableViewCell {

    private struct Constants {
        static let margin: CGFloat = 16
        static let leftMargin: CGFloat = 52
        static let fontSize: CGFloat = 17
    }

}
