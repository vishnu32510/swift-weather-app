import Foundation

// Service to interact with the Gemini LLM API
class LLMService: ObservableObject {
    
    // MARK: - Codable Structs for a more robust Gemini API Request
    
    // Request Structs
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
    
    // Response Structs (these remain the same)
    private struct GeminiResponse: Codable {
        let candidates: [Candidate]
    }
    
    private struct Candidate: Codable {
        let content: Content
    }
    
    // MARK: - Main API Call Function
    
    func fetchSuggestions(for weatherSummary: String) async throws -> String {
        guard let apiKey = APIKeyManager.getAPIKey() else {
            // NEW: Add a specific print statement for this failure case
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
        - Start with an **emoji that represents the activity or location**, not the weather itself.
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
        
        
        // 1. Configure the model's creativity and response length
        let config = GenerationConfig(temperature: 0.7, maxOutputTokens: 100)
        
        // 2. Define safety settings to block harmful content (using standard defaults)
        let safety = [
            SafetySetting(category: "HARM_CATEGORY_HARASSMENT", threshold: "BLOCK_MEDIUM_AND_ABOVE"),
            SafetySetting(category: "HARM_CATEGORY_HATE_SPEECH", threshold: "BLOCK_MEDIUM_AND_ABOVE"),
            SafetySetting(category: "HARM_CATEGORY_SEXUALLY_EXPLICIT", threshold: "BLOCK_MEDIUM_AND_ABOVE"),
            SafetySetting(category: "HARM_CATEGORY_DANGEROUS_CONTENT", threshold: "BLOCK_MEDIUM_AND_ABOVE")
        ]
        
        // 3. Create the complete request body
        let requestBody = GeminiRequest(
            contents: [Content(parts: [Part(text: prompt)])],
            generationConfig: config,
            safetySettings: safety
        )
        // --- END OF CORRECTION ---
        
        request.httpBody = try JSONEncoder().encode(requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            // If there's still an error, print the response data to see the server's message
            if let errorData = String(data: data, encoding: .utf8) {
                print("❌ Server returned an error: \(errorData)")
            }
            throw URLError(.badServerResponse)
        }
        
        let geminiResponse = try JSONDecoder().decode(GeminiResponse.self, from: data)
        return geminiResponse.candidates.first?.content.parts.first?.text ?? "No suggestions available at this time."
    }
}
