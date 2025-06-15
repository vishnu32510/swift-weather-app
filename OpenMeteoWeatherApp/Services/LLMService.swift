import Foundation

class LLMService: ObservableObject {
    

    

    private struct GeminiRequest: Codable {
        let contents: [Content]
        let generationConfig: GenerationConfig
        let safetySettings: [SafetySetting]
    }
    
    private struct Content: Codable {
        let parts: [Part]
    }
    
    private struct Part: Codable {
        let text: String
    }
    
    private struct GenerationConfig: Codable {
        let temperature: Double
        let maxOutputTokens: Int
    }
    
    private struct SafetySetting: Codable {
        let category: String
        let threshold: String
    }
    

    private struct GeminiResponse: Codable {
        let candidates: [Candidate]
    }
    
    private struct Candidate: Codable {
        let content: Content
    }
    

    
    func fetchSuggestions(for weatherSummary: String) async throws -> String {
        guard let apiKey = APIKeyManager.getAPIKey() else {
        
            print("❌ DEBUG: APIKeyManager.getAPIKey() returned nil. The key is NOT in the bundle.")
            throw URLError(.userAuthenticationRequired)
        }
        
        let urlString = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=\(apiKey)"
//        print("✅ DEBUG: Attempting to use URL String: \(urlString)")
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let prompt = """
        You are a weather-based activity recommender. Based on the weather summary below, suggest one perfect activity.
        
        🎯 Response Rules:
        - Respond in **ONE short line only**.
        - Start with an **emoji that represents the activity or location**, not the weather itself, do not use weather emoji, use activity emoji that is present/relative/relatable in the "expressive phrases".
        - Use expressive phrases like:
          - "Great day for..."
          - "Cozy day to..."
          - "Perfect time to..."
          - "Energetic day for..."
          - "Blissful day for..."
          - "Stay in and..."
        - Make the activity **specific to time of day (day/night), location, and weather**.
        - Make it creative, helpful, and personalized.
        
        🛌 Special Case:
        - If it’s sleep time (late night), suggest resting or sleeping well to start a fresh day.
        
        📦 Example Responses:
        📖 Cozy day to curl up with a book by the window.  
        🏖️ Blissful day for a beach stroll with ocean breeze.  
        🚴 Energetic day for biking through the lakeside trail.  
        🎮 Rainy day to stay in and catch up on gaming.  
        🎬 Great day for Netflix and a warm blanket.
        
        📍 Weather Summary:
        \(weatherSummary)
        """
        
        print(prompt)
        
        
    
        let config = GenerationConfig(temperature: 0.7, maxOutputTokens: 100)
        
    
        let safety = [
            SafetySetting(category: "HARM_CATEGORY_HARASSMENT", threshold: "BLOCK_MEDIUM_AND_ABOVE"),
            SafetySetting(category: "HARM_CATEGORY_HATE_SPEECH", threshold: "BLOCK_MEDIUM_AND_ABOVE"),
            SafetySetting(category: "HARM_CATEGORY_SEXUALLY_EXPLICIT", threshold: "BLOCK_MEDIUM_AND_ABOVE"),
            SafetySetting(category: "HARM_CATEGORY_DANGEROUS_CONTENT", threshold: "BLOCK_MEDIUM_AND_ABOVE")
        ]
        
    
        let requestBody = GeminiRequest(
            contents: [Content(parts: [Part(text: prompt)])],
            generationConfig: config,
            safetySettings: safety
        )
    
        
        request.httpBody = try JSONEncoder().encode(requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
        
            if let errorData = String(data: data, encoding: .utf8) {
                print("❌ Server returned an error: \(errorData)")
            }
            throw URLError(.badServerResponse)
        }
        
        let geminiResponse = try JSONDecoder().decode(GeminiResponse.self, from: data)
        return geminiResponse.candidates.first?.content.parts.first?.text ?? "No suggestions available at this time."
    }
    
    

        func generateWeatherAlert(for eventSummary: String) async throws -> String {
            guard let apiKey = APIKeyManager.getAPIKey() else {
                throw URLError(.userAuthenticationRequired)
            }
            
            let urlString = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=\(apiKey)"
            guard let url = URL(string: urlString) else { throw URLError(.badURL) }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            let prompt = """
            You are a helpful assistant that writes weather alerts. Based on the summary provided, create a notification.

            **RESPONSE RULES:**
            1.  Create a short, catchy **Title** and a helpful, one-sentence **Body**.
            2.  The Body MUST include a relevant emoji.
            3.  Format your entire response as a single line: **Title|Body**
            4.  Do NOT include any other text, explanations, or formatting.

            **EXAMPLES:**
            - Input: "Upcoming weather event in Millennium Park: heavy rain with a temperature of 15°C."
            - Output: Heads Up!|Heavy rain is starting soon, you might want to grab an umbrella! ☔️

            - Input: "Upcoming weather event in your area: heavy snow fall with a temperature of -2°C."
            - Output: Snow Alert|Heavy snow is expected. Time to wear a warm jacket! 🧥

            **EVENT SUMMARY:**
            \(eventSummary)
            """
            
            print(prompt)
            
            
        
            let config = GenerationConfig(temperature: 0.7, maxOutputTokens: 100)
            
        
            let safety = [
                SafetySetting(category: "HARM_CATEGORY_HARASSMENT", threshold: "BLOCK_MEDIUM_AND_ABOVE"),
                SafetySetting(category: "HARM_CATEGORY_HATE_SPEECH", threshold: "BLOCK_MEDIUM_AND_ABOVE"),
                SafetySetting(category: "HARM_CATEGORY_SEXUALLY_EXPLICIT", threshold: "BLOCK_MEDIUM_AND_ABOVE"),
                SafetySetting(category: "HARM_CATEGORY_DANGEROUS_CONTENT", threshold: "BLOCK_MEDIUM_AND_ABOVE")
            ]
            
        
            let requestBody = GeminiRequest(
                contents: [Content(parts: [Part(text: prompt)])],
                generationConfig: config,
                safetySettings: safety
            )
        
            
            request.httpBody = try JSONEncoder().encode(requestBody)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw URLError(.badServerResponse)
            }
            
            let geminiResponse = try JSONDecoder().decode(GeminiResponse.self, from: data)
            return geminiResponse.candidates.first?.content.parts.first?.text ?? "Alert|Weather is approaching."
        }
}
