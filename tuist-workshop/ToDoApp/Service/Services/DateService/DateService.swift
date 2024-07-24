//
//  DateService.swift
//  ToDoApp
//
//

import Foundation

protocol DateService {
    func getString(from date: Date?) -> String?
    func getNextDay() -> Date?
}
