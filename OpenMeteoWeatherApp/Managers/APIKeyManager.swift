//
//  APIKeyManager.swift
//  OpenMeteoWeatherApp
//
//  Created by Vishnu Priyan Sellam Shanmugavel on 6/15/25.
//

import Foundation

enum APIKeyManager {
    static func getAPIKey() -> String? {
        guard let path = Bundle.main.path(forResource: "Info", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path),
              let key = plist["GEMINI_API_KEY"] as? String else {
            print("Error: Could not find GEMINI_API_KEY in Info.plist")
            return nil
        }
        return key
    }
}
