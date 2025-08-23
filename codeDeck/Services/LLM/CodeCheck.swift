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
                executionOutput: nil
            )
        }
        
        let prompt = buildComparisonPrompt(userCode: trimmedCode, problem: problem, referenceSolution: solution)
        
        print("SENDING COMPARISON ANALYSIS REQUEST")
        
        let req = OllamaRequest(
            model: model,
            prompt: prompt,
            stream: false
        )

        let endpoint = baseURL.appendingPathComponent("/api/generate")
        
        let startTime = Date()
        let data = try await postJSON(to: endpoint, body: req)
        _ = Date().timeIntervalSince(startTime)
        
        let ollama = try JSONDecoder().decode(OllamaResponse.self, from: data)
        
        
        let result = parseToStrictJSON(ollama.response)
        

        return result
    }
}

private extension CodeCheckingService {
    func buildComparisonPrompt(userCode: String, problem: Problem, referenceSolution: String) -> String {
        """
        You are a strict code comparator. Compare the USER CODE to the REFERENCE SOLUTION.

        GOAL: Determine if the USER CODE is functionally equivalent to the REFERENCE SOLUTION.
        Functional equivalence means:
        - Produces the same outputs for all valid inputs
        - Preserves return values, loops, and conditionals
        - Variable names, formatting, or minor ordering differences DO NOT matter
        - If USER CODE omits or changes essential functionality (e.g., missing return, incorrect loop condition, altered logic), mark it incorrect

        EDGE CASES:
        - Different variable names → still correct
        - Extra print/logging statements → still correct
        - Missing return, wrong condition, or incorrect calculation → incorrect
        - Code that only partially solves the problem → incorrect
        - Structural reordering (helper functions, inline vs extract) → correct if functionality is preserved

        PROBLEM: \(problem.title)

        REFERENCE SOLUTION:
        \(referenceSolution)

        USER CODE:
        \(userCode)

        Return ONLY valid JSON with no extra text, markdown, or formatting:
        {
          "isCorrect": true/false,
          "feedback": "One short sentence explaining if the user code matches the reference solution functionality.",
          "suggestions": [],
          "errors": []
        }
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
