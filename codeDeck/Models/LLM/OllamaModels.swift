//
//  OllamaModels.swift
//  codeDeck
//
//  Created by Meenakshi Gopalakrishnan on 2025-08-18.
//

import Foundation

// request sent to Ollama /api/generate
struct OllamaRequest: Codable {
    let model: String
    let prompt: String
    let stream: Bool
}

// Non-streaming response (stream=false)
struct OllamaResponse: Codable {
    let model: String?
    let created_at: String?
    let response: String
    let done: Bool
}

// JSON response
struct CodeAnalysisResponse: Codable {
    let isCorrect: Bool
    let feedback: String
    let suggestions: [String]
    let errors: [String]
}
