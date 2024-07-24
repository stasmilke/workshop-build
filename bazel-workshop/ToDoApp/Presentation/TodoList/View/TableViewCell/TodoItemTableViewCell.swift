//
//  TodoItemTableViewCell.swift
//  ToDoApp
//
//

import UIKit

final class TodoItemTableViewCell: UITableViewCell {

    struct DisplayData: Hashable {
        let id: UUID
        let text: String
        let importance: Importance
        let deadline: String?
        let isDone: Bool
    }

    var checkmarkCallback: ((UUID) -> Void)?
    var displayedItemID: UUID?

    // MARK: - Private Properties

    private lazy var titleLabel = UILabel()
    private lazy var checkmarkButton = UIButton()
    private lazy var importanceImageView = UIImageView()
    private lazy var calendarImageView = UIImageView()
    private lazy var dateLabel = UILabel()

    private var titleLabelLeadingAnchorConstraint: NSLayoutConstraint?
    private var titleLabelTopAnchorConstraint: NSLayoutConstraint?
    private var titleLabelBottomAnchorConstraint: NSLayoutConstraint?

    // MARK: - Life Cycle

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor(named: "BackSecondary")

        setupCheckmarkButton()
        setupTitleLabel()
        setupImportanceImageView()
        setupCalendarImageView()
        setupDateLabel()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.attributedText = nil
        importanceImageView.image = nil
        dateLabel.text = nil
        checkmarkButton.setImage(nil, for: .normal)
        calendarImageView.isHidden = true
        titleLabelLeadingAnchorConstraint?.constant = Constants.leftMargin
        titleLabelTopAnchorConstraint?.constant = Constants.margin
        titleLabelBottomAnchorConstraint?.constant = -Constants.margin
    }

    // MARK: - UI Setup

    private func setupCheckmarkButton() {
        checkmarkButton.addAction(
            UIAction(handler: { [weak self] _ in
                if let checkmarkCallback = self?.checkmarkCallback,
                   let displayedItemID = self?.displayedItemID {
                    checkmarkCallback(displayedItemID)
                }
            }),
            for: .touchUpInside
        )
        checkmarkButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(checkmarkButton)

        NSLayoutConstraint.activate([
            checkmarkButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.margin),
            checkmarkButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkmarkButton.widthAnchor.constraint(equalToConstant: Constants.checkmarkSize),
            checkmarkButton.heightAnchor.constraint(equalToConstant: Constants.checkmarkSize)
        ])
    }

    private func setupTitleLabel() {
        titleLabel.numberOfLines = 3
        titleLabel.font = .systemFont(ofSize: Constants.fontSize, weight: .regular)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)

        titleLabelLeadingAnchorConstraint = NSLayoutConstraint(
            item: titleLabel, attribute: .leading, relatedBy: .equal,
            toItem: contentView, attribute: .leading, multiplier: 1, constant: Constants.leftMargin
        )
        titleLabelTopAnchorConstraint = NSLayoutConstraint(
            item: titleLabel, attribute: .top, relatedBy: .equal,
            toItem: contentView, attribute: .top, multiplier: 1, constant: Constants.margin
        )
        titleLabelBottomAnchorConstraint = NSLayoutConstraint(
            item: titleLabel, attribute: .bottom, relatedBy: .equal,
            toItem: contentView, attribute: .bottom, multiplier: 1, constant: -Constants.margin
        )
        titleLabel.trailingAnchor.constraint(
            equalTo: contentView.trailingAnchor,
            constant: -Constants.margin
        ).isActive = true

        titleLabelLeadingAnchorConstraint?.isActive = true
        titleLabelTopAnchorConstraint?.isActive = true
        titleLabelTopAnchorConstraint?.priority = UILayoutPriority(999)
        titleLabelBottomAnchorConstraint?.isActive = true
        titleLabelBottomAnchorConstraint?.priority = UILayoutPriority(999)
    }

    private func setupImportanceImageView() {
        importanceImageView.contentMode = .scaleAspectFill
        importanceImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(importanceImageView)

        NSLayoutConstraint.activate([
            importanceImageView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            importanceImageView.widthAnchor.constraint(equalToConstant: Constants.importanceImageWidth),
            importanceImageView.heightAnchor.constraint(equalToConstant: Constants.importanceImageHeight),
            importanceImageView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: Constants.leftMargin
            )
        ])
    }

    private func setupCalendarImageView() {
        calendarImageView.image = UIImage(systemName: "calendar")?
            .withTintColor(UIColor(named: "LabelTertiary") ?? .gray, renderingMode: .alwaysOriginal)
        calendarImageView.isHidden = true
        calendarImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(calendarImageView)

        NSLayoutConstraint.activate([
            calendarImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Constants.smallMargin),
            calendarImageView.widthAnchor.constraint(equalToConstant: Constants.calendarSize),
            calendarImageView.heightAnchor.constraint(equalToConstant: Constants.calendarSize),
            calendarImageView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: Constants.leftMargin
            )
        ])
    }

    private func setupDateLabel() {
        dateLabel.textColor = UIColor(named: "LabelTertiary")
        dateLabel.font = .systemFont(ofSize: Constants.smallFontSize, weight: .regular)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(dateLabel)

        NSLayoutConstraint.activate([
            dateLabel.centerYAnchor.constraint(equalTo: calendarImageView.centerYAnchor),
            dateLabel.leadingAnchor.constraint(
                equalTo: calendarImageView.trailingAnchor,
                constant: Constants.smallMargin
            )
        ])
    }

}

// MARK: - Configurable

extension TodoItemTableViewCell: Configurable {

    func configure(with model: DisplayData) {
        displayedItemID = model.id
        titleLabel.attributedText = getAttributedText(text: model.text, isDone: model.isDone)
        if let importanceImage = getImportanceImage(importance: model.importance) {
            importanceImageView.image = importanceImage
            offsetTitleLabelLeadingAnchorConstraint()
        }
        let checkmark = getCheckmarkImage(isDone: model.isDone, importance: model.importance)
        checkmarkButton.setImage(checkmark, for: .normal)
        if let deadline = model.deadline {
            dateLabel.text = deadline
            calendarImageView.isHidden = false
            offsetTitleLabelVerticalAnchorConstraints()
        }
    }

    private func getCheckmarkImage(isDone: Bool, importance: Importance) -> UIImage? {
        if isDone {
            return UIImage(named: "GreenCircle")
        } else if importance == .important {
            return UIImage(named: "RedCircle")
        } else {
            let image = UIImage(named: "GrayCircle")?
                .withTintColor(
                    UIColor(named: "Separator")?.withAlphaComponent(1) ?? .gray,
                    renderingMode: .alwaysOriginal
                )
            return image
        }
    }

    private func getAttributedText(text: String, isDone: Bool) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: text)
        let range = NSRange(location: 0, length: attributedString.length)
        if isDone {
            attributedString.addAttribute(
                NSAttributedString.Key.strikethroughStyle,
                value: 1,
                range: range)
            attributedString.addAttribute(
                NSAttributedString.Key.foregroundColor,
                value: UIColor(named: "LabelTertiary") as Any,
                range: range
            )
        }
        return attributedString
    }

    private func getImportanceImage(importance: Importance) -> UIImage? {
        switch importance {
        case .important:
            let scaleConfig = UIImage.SymbolConfiguration(scale: .small)
            let weightConfig = UIImage.SymbolConfiguration(weight: .bold)
            let exclamationmarkImage = UIImage(
                systemName: "exclamationmark.2",
                withConfiguration: scaleConfig.applying(weightConfig)
            )?.withTintColor(UIColor(named: "Red") ?? .red, renderingMode: .alwaysOriginal)
            return exclamationmarkImage
        case .unimportant:
            let scaleConfig = UIImage.SymbolConfiguration(scale: .small)
            let weightConfig = UIImage.SymbolConfiguration(weight: .bold)
            let arrowImage = UIImage(
                systemName: "arrow.down",
                withConfiguration: scaleConfig.applying(weightConfig)
            )?.withTintColor(UIColor(named: "Gray") ?? .gray, renderingMode: .alwaysOriginal)
            return arrowImage
        case .regular:
            return nil
        }
    }

    private func offsetTitleLabelLeadingAnchorConstraint() {
        titleLabelLeadingAnchorConstraint?.constant = Constants.bigLeftMargin
    }

    private func offsetTitleLabelVerticalAnchorConstraints() {
        titleLabelTopAnchorConstraint?.constant = Constants.mediumMargin
        titleLabelBottomAnchorConstraint?.constant = -32
    }

}

// MARK: - Constants

extension TodoItemTableViewCell {

    private struct Constants {
        static let margin: CGFloat = 16
        static let mediumMargin: CGFloat = 12
        static let smallMargin: CGFloat = 2
        static let leftMargin: CGFloat = 52
        static let bigLeftMargin: CGFloat = 70
        static let fontSize: CGFloat = 17
        static let smallFontSize: CGFloat = 15
        static let importanceImageWidth: CGFloat = 16
        static let importanceImageHeight: CGFloat = 20
        static let checkmarkSize: CGFloat = 24
        static let calendarSize: CGFloat = 16
    }

}
