import Foundation

// request sent to Ollama /api/generate
struct OllamaRequest: Codable {
    let model: String
    let prompt: String
    let stream: Bool
}

// non-streaming response (stream=false)
struct OllamaResponse: Codable {
    let model: String?
    let created_at: String?
    let response: String
    let done: Bool
}
