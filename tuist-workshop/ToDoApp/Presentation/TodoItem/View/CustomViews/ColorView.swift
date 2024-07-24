import UIKit

final class ColorView: UIView {

    var paletteButtonTapped: (() -> Void)?

    private lazy var colorLabel = UILabel()
    private lazy var selectedColorLabel = UILabel()
    private lazy var paletteButton = UIButton()
    private lazy var separator = UIView()

    func getTextColor() -> UIColor {
        selectedColorLabel.textColor
    }

    func setTextColor(_ color: UIColor) {
        selectedColorLabel.textColor = color
    }

    func setText(_ text: String) {
        selectedColorLabel.text = text
    }

    override func draw(_ rect: CGRect) {
        setupColorLabel()
        setupSelectedColorLabel()
        setupPaletteButton()
        setupSeparator()
    }

    private func setupColorLabel() {
        colorLabel.text = L10n.colorLabelText
        colorLabel.font = .systemFont(ofSize: Constants.fontSize, weight: .regular)
        colorLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(colorLabel)

        NSLayoutConstraint.activate([
            colorLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: Constants.margin),
            colorLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }

    private func setupSelectedColorLabel() {
        selectedColorLabel.font = .systemFont(ofSize: Constants.fontSize, weight: .regular)
        selectedColorLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(selectedColorLabel)

        NSLayoutConstraint.activate([
            selectedColorLabel.leadingAnchor.constraint(equalTo: colorLabel.trailingAnchor),
            selectedColorLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }

    private func setupPaletteButton() {
        let scaleConfig = UIImage.SymbolConfiguration(scale: .large)
        let weightConfig = UIImage.SymbolConfiguration(weight: .medium)
        paletteButton.setImage(
            UIImage(systemName: "paintpalette", withConfiguration: scaleConfig.applying(weightConfig)),
            for: .normal
        )
        paletteButton.translatesAutoresizingMaskIntoConstraints = false
        paletteButton.addAction(
            UIAction(handler: { [weak self] _ in
                if let toggleColorPickerVisibility = self?.paletteButtonTapped {
                    toggleColorPickerVisibility()
                }
            }),
            for: .touchUpInside
        )
        self.addSubview(paletteButton)

        NSLayoutConstraint.activate([
            paletteButton.trailingAnchor.constraint(
                equalTo: self.trailingAnchor,
                constant: -Constants.mediumMargin
            ),
            paletteButton.centerYAnchor.constraint(equalTo: self.centerYAnchor)
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

extension ColorView {
    private struct Constants {
        static let margin: CGFloat = 16
        static let mediumMargin: CGFloat = 12
        static let fontSize: CGFloat = 17
        @MainActor static let separatorHeight: CGFloat = 1 / UIScreen.main.scale
    }
}
