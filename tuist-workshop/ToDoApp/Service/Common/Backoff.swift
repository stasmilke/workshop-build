//
//  Backoff.swift
//  ToDoApp
//
//

import Foundation

struct Backoff {
    static let minDelay = 2
    static let maxDelay = 120
    static let factor = 1.5
    static let jitter = 0.05

    static func getNextDelay(from delay: Int) -> Int {
        var nextDelay = min(Double(delay) * factor, Double(maxDelay))
        nextDelay += nextDelay * Double.random(in: 0 ... jitter)
        return Int(nextDelay)
    }
}
