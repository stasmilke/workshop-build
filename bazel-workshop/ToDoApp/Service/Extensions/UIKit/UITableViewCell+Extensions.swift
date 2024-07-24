//
//  UITableViewCell+Extensions.swift
//  ToDoApp
//
//

import Foundation
import UIKit

extension UITableViewCell {
    static var reuseIdentifier: String {
        String(describing: Self.self)
    }
}
