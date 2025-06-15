//
//  DateHelper.swift
//  OpenMeteoWeatherApp
//
//  Created by Vishnu Priyan Sellam Shanmugavel on 6/15/25.
//

import Foundation

enum DateHelper {
    
    // The single, efficient parser for all dates from the API (e.g., "2025-06-15T05:45").
    private static let apiDateParser: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX") // Ensures consistency
        formatter.timeZone = TimeZone(secondsFromGMT: 0) // Assume API sends UTC
        return formatter
    }()

    /// Formats a date string from the API into a localized time (e.g., "5:45 PM").
    /// Perfect for Sunrise and Sunset.
    static func formatTime(from dateString: String) -> String {
        guard let date = apiDateParser.date(from: dateString) else {
            return "N/A"
        }
        // This provides a clean, localized time format (e.g., 5:45 PM)
        return date.formatted(date: .omitted, time: .shortened)
    }

    /// Formats a date string from the API into an hourly format (e.g., "5PM").
    /// Perfect for the hourly forecast row.
    static func formatHour(from dateString: String) -> String {
        guard let date = apiDateParser.date(from: dateString) else {
            return "N/A"
        }
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "ha" // "5PM"
        return displayFormatter.string(from: date).uppercased()
    }

    /// Finds the index of the current hour within an array of date strings.
    static func findCurrentHourIndex(in timeStrings: [String]) -> Int {
        let now = Date()
        // Find the first time in the future
        return timeStrings.firstIndex { timeString in
            apiDateParser.date(from: timeString)?.timeIntervalSince(now) ?? -1 >= 0
        } ?? 0
    }
}
