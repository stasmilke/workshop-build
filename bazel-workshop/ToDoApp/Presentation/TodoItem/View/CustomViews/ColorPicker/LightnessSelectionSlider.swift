//
//  LightnessSelectionSlider.swift
//  LightnessSelectionSlider
//
//

import UIKit
import Foundation

final class LightnessSelectionSlider: ColorfulSlider {

    private(set) var lightness: Float = Constants.defaultLightness
    var lightnessChanged: ((Float) -> Void)?
    var mainColor: UIColor = Constants.defaultMainColor {
        didSet {
            changeColors(colors: getColors())
        }
    }

    init() {
        super.init(
            minimumValue: Constants.minLightness,
            maximumValue: Constants.maxLightness,
            defaultValue: Constants.defaultLightness,
            colors: Constants.defaultColors
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func getColors() -> [CGColor] {
        let colors = [
            mainColor.adjustLightness(by: Constants.minLightness).cgColor,
            mainColor.cgColor,
            mainColor.adjustLightness(by: Constants.maxLightness).cgColor
        ]
        return colors
    }

    // MARK: - Actions

    @objc override func colorValueChanged() {
        lightness = self.value
        if let lightnessChanged = lightnessChanged {
            lightnessChanged(lightness)
        }
    }

}

// MARK: - Constants

extension LightnessSelectionSlider {
    private struct Constants {
        static let minLightness: Float = -0.75
        static let maxLightness: Float = 0.75
        static let defaultLightness: Float = 0
        static let defaultMainColor: UIColor = .red
        static let defaultColors: [CGColor] = [
            defaultMainColor.adjustLightness(by: Constants.minLightness).cgColor,
            defaultMainColor.cgColor,
            defaultMainColor.adjustLightness(by: Constants.maxLightness).cgColor
        ]
    }
}
