//
//  DateHelper.swift
//  OpenMeteoWeatherApp
//
//  Created by Vishnu Priyan Sellam Shanmugavel on 6/15/25.
//

import Foundation

enum DateHelper {
    
    static func date(from dateString: String) -> Date? {
            return apiDateParser.date(from: dateString)
        }
    
    private static let apiDateParser: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
    
    static func formatTime(from dateString: String) -> String {
        guard let date = apiDateParser.date(from: dateString) else {
            return "N/A"
        }
    
        return date.formatted(date: .omitted, time: .shortened)
    }

    static func formatHour(from dateString: String) -> String {
        guard let date = apiDateParser.date(from: dateString) else {
            return "N/A"
        }
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "ha"
        return displayFormatter.string(from: date).uppercased()
    }

    static func findCurrentHourIndex(in timeStrings: [String]) -> Int {
        let now = Date()
        return timeStrings.firstIndex { timeString in
            apiDateParser.date(from: timeString)?.timeIntervalSince(now) ?? -1 >= 0
        } ?? 0
    }
}
