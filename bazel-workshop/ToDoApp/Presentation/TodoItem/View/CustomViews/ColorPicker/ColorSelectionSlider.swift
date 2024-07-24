//
//  ColorSelectionSlider.swift
//  ColorSelectionSlider
//
//

import UIKit
import Foundation

final class ColorSelectionSlider: ColorfulSlider {

    private(set) var color: UIColor = .red
    var colorChanged: ((UIColor) -> Void)?

    init() {
        super.init(
            minimumValue: Constants.minValue,
            maximumValue: Constants.maxValue,
            defaultValue: Constants.minValue,
            colors: Constants.colors
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Actions

    @objc override func colorValueChanged() {
        let value = round(self.value)
        color = getColorBy(number: Int(value))
        if let colorChanged = colorChanged {
            colorChanged(color)
        }
    }

}

// MARK: - Colors

extension ColorSelectionSlider {
    private struct Colors {
        static let red = UIColor(red: 1, green: 0, blue: 0, alpha: 1)
        static let yellow = UIColor(red: 1, green: 1, blue: 0, alpha: 1)
        static let green = UIColor(red: 0, green: 1, blue: 0, alpha: 1)
        static let lightBlue = UIColor(red: 0, green: 1, blue: 1, alpha: 1)
        static let blue = UIColor(red: 0, green: 0, blue: 1, alpha: 1)
        static let pink = UIColor(red: 1, green: 0, blue: 1, alpha: 1)
    }

    private func getColorBy(number: Int) -> UIColor {
        switch number {
        case 1, 7:
            return Colors.red
        case 2:
            return Colors.yellow
        case 3:
            return Colors.green
        case 4:
            return Colors.lightBlue
        case 5:
            return Colors.blue
        case 6:
            return Colors.pink
        default:
            return color
        }
    }
}

// MARK: - Constants

extension ColorSelectionSlider {
    private struct Constants {
        static let minValue: Float = 1
        static let maxValue: Float = 7
        static let colors: [CGColor] = [
            Colors.red.cgColor,
            Colors.yellow.cgColor,
            Colors.green.cgColor,
            Colors.lightBlue.cgColor,
            Colors.blue.cgColor,
            Colors.pink.cgColor,
            Colors.red.cgColor
        ]
    }
}
