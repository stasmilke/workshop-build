//
//  ColorPickerView.swift
//  ToDoApp
//
//

import UIKit

final class ColorPickerView: UIView {

    var colorChanged: ((UIColor) -> Void)?

    private lazy var colorSlider = ColorSelectionSlider()
    private lazy var lightnessSlider = LightnessSelectionSlider()
    private lazy var separator = UIView()

    override func draw(_ rect: CGRect) {
        setupColorSlider()
        setupLightnessSlider()
        setupSeparator()
    }

    private func setupColorSlider() {
        colorSlider.colorChanged = { [weak self] color in
            self?.lightnessSlider.mainColor = color
            if let colorChanged = self?.colorChanged,
               let color = self?.getColor() {
                colorChanged(color)
            }
        }
        colorSlider.bounds = CGRect(x: 0, y: 0, width: self.frame.width, height: Constants.sliderHeight)
        colorSlider.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(colorSlider)

        NSLayoutConstraint.activate([
            colorSlider.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: Constants.margin),
            colorSlider.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -Constants.margin),
            colorSlider.bottomAnchor.constraint(equalTo: self.centerYAnchor, constant: -Constants.margin),
            colorSlider.heightAnchor.constraint(equalToConstant: Constants.sliderHeight)
        ])
    }

    private func setupLightnessSlider() {
        lightnessSlider.lightnessChanged = { [weak self] _ in
            if let colorChanged = self?.colorChanged,
               let color = self?.getColor() {
                colorChanged(color)
            }
        }
        lightnessSlider.mainColor = colorSlider.color
        lightnessSlider.bounds = CGRect(x: 0, y: 0, width: self.frame.width, height: Constants.sliderHeight)
        lightnessSlider.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(lightnessSlider)

        NSLayoutConstraint.activate([
            lightnessSlider.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: Constants.margin),
            lightnessSlider.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -Constants.margin),
            lightnessSlider.topAnchor.constraint(equalTo: self.centerYAnchor, constant: Constants.margin),
            lightnessSlider.heightAnchor.constraint(equalToConstant: Constants.sliderHeight)
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

    private func getColor() -> UIColor {
        colorSlider.color.adjustLightness(by: lightnessSlider.lightness)
    }

}

extension ColorPickerView {
    private struct Constants {
        static let margin: CGFloat = 16
        static let sliderHeight: CGFloat = 12
        @MainActor static let separatorHeight: CGFloat = 1 / UIScreen.main.scale
    }
}
