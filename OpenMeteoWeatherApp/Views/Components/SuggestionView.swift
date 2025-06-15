//
//  SuggestionView.swift
//  OpenMeteoWeatherApp
//
//  Created by Vishnu Priyan Sellam Shanmugavel on 6/15/25.
//
import SwiftUI

struct SuggestionView: View {
    let suggestionText: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(suggestionText)
                .font(.body)
                .lineLimit(2)
                .padding(.top, 4)
        }
        .foregroundColor(.white)
        .padding()
        .background(.white.opacity(0.1))
        .cornerRadius(15)
        .padding(.horizontal)
    }
}
