//
//  CodeCheck.swift
//  codeDeck
//
//  Created by Meenakshi Gopalakrishnan on 2025-08-18.
//

import Foundation


protocol CodeCheckingServiceProtocol {
    func checkCode(_ code: String, for problem: Problem) async throws -> CodeCheckResult
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

    func checkCode(_ code: String, for problem: Problem) async throws -> CodeCheckResult {
        let prompt = buildPrompt(code: code, problem: problem)

        let req = OllamaRequest(
            model: model,
            prompt: prompt,
            stream: false
        )

        let endpoint = baseURL.appendingPathComponent("/api/generate")
        let data = try await postJSON(to: endpoint, body: req)

        // decode ollama response
        let ollama = try JSONDecoder().decode(OllamaResponse.self, from: data)

        // parse analysis json inside ollama.response
        return parseAnalysisJSON(from: ollama.response)
    }
}

private extension CodeCheckingService {
    func buildPrompt(code: String, problem: Problem) -> String {
        let trimmedCode = code.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return """
        You are a code reviewer. Analyze the Python solution and respond with ONLY valid JSON.

        RULES:
        - If code is empty/whitespace only: mark as incorrect, ask for solution
        - If code is not Python or irrelevant: mark as incorrect, explain issue
        - If code has syntax errors: mark as incorrect, list specific errors
        - If code is correct: provide brief positive feedback (max 50 words)
        - If code is incorrect: explain what's wrong briefly (max 50 words)
        - Always include time/space complexity for valid Python code
        - Suggestions should be actionable (max 3 items)
        
        OUTPUT FORMAT (JSON only):
        {
          "isCorrect": boolean,
          "feedback": "Brief explanation (max 50 words)",
          "suggestions": ["actionable tip 1", "actionable tip 2"],
          "errors": ["specific error 1", "specific error 2"],
          "timeComplexity": "O(n) or null if not applicable",
          "spaceComplexity": "O(1) or null if not applicable"
        }

        PROBLEM:
        Title: \(problem.title)
        Difficulty: \(problem.difficulty.rawValue)
        Description: \(problem.description ?? "No description provided")
        Example: \(problem.example ?? "No example provided")

        USER SOLUTION:
        \(trimmedCode.isEmpty ? "[EMPTY SUBMISSION]" : "```python\n\(trimmedCode)\n```")

        EXAMPLES:
        Empty: {"isCorrect": false, "feedback": "No solution provided.", "suggestions": ["Write a function to solve the problem"], "errors": ["No code"], "timeComplexity": null, "spaceComplexity": null}
        
        Correct: {"isCorrect": true, "feedback": "Correct solution with proper logic.", "suggestions": [], "errors": [], "timeComplexity": "O(n)", "spaceComplexity": "O(1)"}
        
        Wrong: {"isCorrect": false, "feedback": "Logic error in main algorithm.", "suggestions": ["Fix the loop condition", "Handle edge cases"], "errors": ["Incorrect comparison"], "timeComplexity": "O(n²)", "spaceComplexity": "O(n)"}

        Respond with JSON only. No explanatory text before or after.
        """
    }
}

private extension CodeCheckingService {
    func parseAnalysisJSON(from text: String) -> CodeCheckResult {
        // regex to extract { ... }
        let pattern = #"\{[\s\S]*\}"#
        let regex = try? NSRegularExpression(pattern: pattern)
        let range = NSRange(location: 0, length: text.utf16.count)

        guard let match = regex?.firstMatch(in: text, range: range),
              let r = Range(match.range, in: text)
        else {
            return CodeCheckResult(
                isCorrect: false,
                feedback: "Could not parse JSON from response.",
                suggestions: [],
                errors: ["Parse error"],
                timeComplexity: nil,
                spaceComplexity: nil,
                executionOutput: nil

            )
        }

        let jsonString = String(text[r])
        guard let jsonData = jsonString.data(using: .utf8) else {
            return CodeCheckResult(
                isCorrect: false,
                feedback: "Invalid JSON encoding.",
                suggestions: [],
                errors: ["Encoding error"],
                timeComplexity: nil,
                spaceComplexity: nil,
                executionOutput: nil
            )
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
                executionOutput: nil
            )
        } catch {
            return CodeCheckResult(
                isCorrect: false,
                feedback: "Failed to decode JSON.",
                suggestions: [],
                errors: [error.localizedDescription],
                timeComplexity: nil,
                spaceComplexity: nil,
                executionOutput: nil
            )
        }
    }
}


private extension CodeCheckingService {
    func postJSON<T: Encodable>(to url: URL, body: T) async throws -> Data {
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONEncoder().encode(body)

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse, 200..<300 ~= http.statusCode else {
            throw URLError(.badServerResponse)
        }
        return data
    }
}
