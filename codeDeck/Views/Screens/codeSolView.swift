//
//  CodingSolutionView.swift
//  codeDeck
//
//  Created by Meenakshi Gopalakrishnan on 2025-07-27.
//

import SwiftUI

struct CodingSolutionView: View {
    let problem: Problem
    @State private var userSolution = ""
    @State private var checkResult: CodeCheckResult?
    @State private var isChecking = false
    @State private var errorMessage: String?
    @Environment(\.dismiss) private var dismiss
    
    private let codeChecker = CodeCheckingService()

    var body: some View {
        VStack(spacing: 0) {
            navigationBar
            
            
            VStack(spacing: 16) {
                problemHeader
                    .padding(.horizontal)
                
                codeEditor
                    .frame(maxHeight: .infinity)
                    .padding(.horizontal)
                
                outputSection
                    .padding(.horizontal)
            }
            actionButtons
                .padding()
        }
        .background(Color(.systemBackground))
        .navigationBarHidden(true)
    }
    
    private var navigationBar: some View {
        HStack {
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "arrow.left")
                    .font(.title2)
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            Text(problem.title)
                .font(.headline)
                .fontWeight(.semibold)
                .lineLimit(1)
            
            Spacer()
            
            Button(action: {
                // TODO: Save solution
            }) {
                Image(systemName: "square.and.arrow.down")
                    .font(.title2)
                    .foregroundColor(.primary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    private var problemHeader: some View {
        HStack {
            Text(problem.title)
                .font(.title2)
                .fontWeight(.bold)
            
            Spacer()
            
            Text(problem.difficulty.rawValue)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(problem.difficulty.color.opacity(0.2))
                .foregroundColor(problem.difficulty.color)
                .cornerRadius(12)
        }
    }
    
    private var codeEditor: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Solution")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                // language selector (placeholder)
                Text("Python")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
            }
            
            // code input area
            VStack {
                TextEditor(text: $userSolution)
                    .font(.system(.body, design: .monospaced))
                    .padding(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
                    .frame(minHeight: 400)
                            }
        }
    }
    
    private var outputSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Output")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("Check") {
                    Task { await runCodeCheck() }
                }
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.green)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
//                .background(Color.green)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.green, lineWidth: 1)
                )
            }
            
            
            // Output area
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
                .stroke(Color(.systemGray4), lineWidth: 1)
                .frame(minHeight: 120)
                .overlay(
                    VStack(alignment: .leading, spacing: 8) {
                        if isChecking {
                            ProgressView("Checking solution...")
                        } else if let err = errorMessage {
                            Text(err).foregroundColor(.red)
                        } else if let r = checkResult {
                            // Feedback
                            Text(r.feedback)
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(r.isCorrect ? .green : .red)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.bottom, 6)

                            // Suggestions
                            if !r.suggestions.isEmpty {
                                Text("Suggestions:")
                                    .font(.headline)
                                ForEach(r.suggestions, id: \.self) { s in
                                    Text("• \(s)")
                                        .font(.system(.body, design: .monospaced))
                                }
                            }

                            // Errors
                            if !r.errors.isEmpty {
                                Text("Issues:")
                                    .font(.headline)
                                    .padding(.top, 6)
                                ForEach(r.errors, id: \.self) { e in
                                    Text("• \(e)")
                                        .foregroundColor(.red)
                                        .font(.system(.body, design: .monospaced))
                                }
                            }
                        } else {
                            Text("Run your code to see output")
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                )

        }
    }
    
    private var actionButtons: some View {
        HStack(spacing: 16) {
            Button(action: {
                dismiss()
            }) {
                HStack {
                    Image(systemName: "arrow.left")
                    Text("Back")
                }
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color(.systemGray6))
                .cornerRadius(25)
            }
            
            Spacer()
            

        }
    }
    
    private func runCodeCheck() async {
        isChecking = true
        errorMessage = nil
        defer { isChecking = false }
        do {
            let result = try await codeChecker.checkCode(userSolution, for: problem)
            checkResult = result
        } catch {
            errorMessage = "Failed to check solution: \(error.localizedDescription)"
            checkResult = nil
        }
    }

    
}

// MARK: - Preview
struct CodingSolutionView_Previews: PreviewProvider {
    static var previews: some View {
        CodingSolutionView(
            problem: Problem(
                id: "two-sum",
                title: "Two Sum",
                difficulty: .easy,
                status: .attempted
            )
        )
    }
}
