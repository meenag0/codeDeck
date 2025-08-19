//
//  NetworkManagerExtension.swift
//  codeDeck
//
//  Created by Meenakshi Gopalakrishnan on 2025-08-18.
//


import Foundation

extension NetworkManager {
    
    // POST request for sending code to llm
    func post<T: Codable, R: Codable>(
        url: String,
        body: T,
        headers: [String: String] = [:]
    ) async throws -> R {
        
        guard let url = URL(string: url) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        // encode the body to JSON
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(R.self, from: data)
    }
}
