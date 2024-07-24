//
//  UIColor+Extensions.swift
//  ToDoApp
//
//

import Foundation
import UIKit

extension UIColor {
    func adjustLightness(by value: Float) -> UIColor {
        let value = CGFloat(value)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return UIColor(
                red: max(min(red + value, 1.0), 0.0),
                green: max(min(green + value, 1.0), 0.0),
                blue: max(min(blue + value, 1.0), 0.0),
                alpha: alpha
            )
        } else {
            return self
        }
    }
}

// MARK: - HEX convertation

extension UIColor {

    var hex: String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: nil)
        let rgb: Int = (Int)(red * 255) << 16 | (Int)(green * 255) << 8 | (Int)(blue * 255)
        return NSString(format: "#%06x", rgb) as String
    }

    static func convertHexToUIColor(hex: String) -> UIColor {
        var string: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if string.hasPrefix("#") {
            string.remove(at: string.startIndex)
        }
        if string.count != 6 {
            return .gray
        }
        var rgbValue: UInt64 = 0
        Scanner(string: string).scanHexInt64(&rgbValue)
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: 1.0
        )
    }

}
