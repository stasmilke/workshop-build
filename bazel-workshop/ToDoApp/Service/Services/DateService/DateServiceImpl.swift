//
//  DateServiceImpl.swift
//  ToDoApp
//
//

import Foundation

final class DateServiceImpl: DateService {

    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru")
        return dateFormatter
    }()

    func getString(from date: Date?) -> String? {
        guard let date = date else { return nil }
        let calendar = Calendar.current
        if !(calendar.isDate(date, equalTo: Date(), toGranularity: .year)) {
            dateFormatter.setLocalizedDateFormatFromTemplate("d MMMM yyyy")
        } else if !(calendar.isDateInToday(date)) {
            dateFormatter.setLocalizedDateFormatFromTemplate("d MMMM")
        } else {
            return L10n.today
        }
        return dateFormatter.string(from: date)
    }

    func getNextDay() -> Date? {
        Calendar.current.date(byAdding: .day, value: 1, to: Date())
    }

}
