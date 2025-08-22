//
//  CodeCheck.swift (Updated - Solution Comparison)
//  codeDeck
//

import Foundation

protocol CodeCheckingServiceProtocol {
    func checkCode(_ code: String, for problem: Problem, against solution: String) async throws -> CodeCheckResult
}

final class CodeCheckingService: CodeCheckingServiceProtocol {
    private let baseURL: URL
    private let model: String

    init(baseURL: String = AppConfig.ollamaBaseURL,
         model: String = AppConfig.ollamaModel) {
        guard let url = URL(string: baseURL) else {
            fatalError("Invalid Ollama base URL")
        }
        self.baseURL = url
        self.model = model
        
    }

    func checkCode(_ code: String, for problem: Problem, against solution: String) async throws -> CodeCheckResult {
        
        let trimmedCode = code.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedCode.isEmpty {
            return CodeCheckResult(
                isCorrect: false,
                feedback: "No code provided. Please write a solution to solve the \(problem.title) problem.",
                suggestions: ["Write a function that solves the \(problem.title) problem", "Review the problem description and requirements"],
                errors: ["Empty code submission"],
                timeComplexity: nil,
                spaceComplexity: nil,
                executionOutput: nil
            )
        }
        
        let prompt = buildComparisonPrompt(userCode: trimmedCode, problem: problem, referenceSolution: solution)
        
        print("📨 SENDING COMPARISON ANALYSIS REQUEST")
        
        let req = OllamaRequest(
            model: model,
            prompt: prompt,
            stream: false
        )

        let endpoint = baseURL.appendingPathComponent("/api/generate")
        
        let startTime = Date()
        let data = try await postJSON(to: endpoint, body: req)
        let requestDuration = Date().timeIntervalSince(startTime)
        
        let ollama = try JSONDecoder().decode(OllamaResponse.self, from: data)
        
        
        let result = parseToStrictJSON(ollama.response)
        

        return result
    }
}

private extension CodeCheckingService {
    func buildComparisonPrompt(userCode: String, problem: Problem, referenceSolution: String) -> String {
        """
        Compare the user's code against the reference solution. Determine if they solve the problem using a similar approach.

        PROBLEM: \(problem.title)

        REFERENCE SOLUTION:
        \(referenceSolution)

        USER'S CODE:
        \(userCode)

        Return ONLY valid JSON with no extra text, markdown, or formatting:
        {
          "isCorrect": true/false,
          "feedback": "Brief 1-2 sentence explanation of correctness",
          "suggestions": [],
          "errors": []
        }

        Rules:
        - Mark as correct if the approach is similar and would solve the problem
        - Keep feedback to maximum 2 sentences
        - Leave suggestions and errors arrays empty
        - No newlines in JSON strings
        """
    }
    
    func parseToStrictJSON(_ response: String) -> CodeCheckResult {
        
        let cleanedResponse = response
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        let pattern = #"\{[\s\S]*?\}"#
        let regex = try? NSRegularExpression(pattern: pattern)
        let range = NSRange(location: 0, length: cleanedResponse.utf16.count)
        
        guard let match = regex?.firstMatch(in: cleanedResponse, range: range),
              let r = Range(match.range, in: cleanedResponse) else {
            return createFallbackResult(from: cleanedResponse)
        }
        
        let jsonString = String(cleanedResponse[r])
        
        guard let jsonData = jsonString.data(using: .utf8) else {
            return createFallbackResult(from: cleanedResponse)
        }
        
        do {
            let analysis = try JSONDecoder().decode(CodeAnalysisResponse.self, from: jsonData)
            
            return CodeCheckResult(
                isCorrect: analysis.isCorrect,
                feedback: analysis.feedback,
                suggestions: analysis.suggestions,
                errors: analysis.errors,
                timeComplexity: nil,
                spaceComplexity: nil,
                executionOutput: cleanedResponse
            )
        } catch {
            return createFallbackResult(from: cleanedResponse)
        }
    }
    
    func createFallbackResult(from response: String) -> CodeCheckResult {
        let responseText = response.lowercased()
        let correctWords = ["correct", "right", "good", "similar", "matches", "works"]
        let incorrectWords = ["incorrect", "wrong", "different", "error", "fail", "issue"]
        
        let hasCorrect = correctWords.contains { responseText.contains($0) }
        let hasIncorrect = incorrectWords.contains { responseText.contains($0) }
        
        let isCorrect = hasCorrect && !hasIncorrect
        
        let feedback = if response.count > 50 {
            "Could not parse analysis properly. Your solution appears \(isCorrect ? "correct" : "incorrect") based on basic comparison."
        } else {
            "Analysis parsing failed. Please try again."
        }
        
        return CodeCheckResult(
            isCorrect: isCorrect,
            feedback: feedback,
            suggestions: [],
            errors: [],
            timeComplexity: nil,
            spaceComplexity: nil,
            executionOutput: response
        )
    }
    
}

private extension CodeCheckingService {
    func postJSON<T: Encodable>(to url: URL, body: T) async throws -> Data {
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONEncoder().encode(body)
        req.timeoutInterval = 180 // Reduced timeout for faster response
        
        let (data, resp) = try await URLSession.shared.data(for: req)
        
        guard let http = resp as? HTTPURLResponse, 200..<300 ~= http.statusCode else {
            throw URLError(.badServerResponse)
        }
        
        return data
    }
}

// MARK: - Supporting Types
struct CodeAnalysisResponse: Codable {
    let isCorrect: Bool
    let feedback: String
    let suggestions: [String]
    let errors: [String]
}
