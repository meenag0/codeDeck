//
//  ProblemDetailView.swift
//  codeDeck
//
//  Created by Meenakshi Gopalakrishnan on 2025-07-27.
//


import SwiftUI

struct ProblemDetailView: View {
    let problem: Problem
    @State private var isFlipped = false
    @State private var showingSolution = false
    @State private var showingCodingView = false
    @State private var currProblemStatus: ProblemStatus?

    let onStatusUpdate: ((Problem, ProblemStatus) -> Void)?
    @Environment(\.dismiss) private var dismiss
    
    init(problem: Problem, onStatusUpdate: ((Problem, ProblemStatus) -> Void)? = nil) {
        self.problem = problem
        self.onStatusUpdate = onStatusUpdate
        self._currProblemStatus = State(initialValue: problem.status)
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                navigationBar
                flashcard
                    .frame(maxWidth: .infinity)
                    .frame(maxHeight: .infinity)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                
                actionButtons
            }
        }
        .background(Color(.systemBackground))
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $showingCodingView) {
            CodingSolutionView(problem: problem)
        }
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
            
            // Status
            if let status = problem.status {
                Image(systemName: status.icon)
                    .foregroundColor(status.color)
                    .font(.title2)
            } else {
                // Invisible placeholder to keep title centered
                Image(systemName: "circle")
                    .foregroundColor(.clear)
                    .font(.title2)
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
        
    private var flashcard: some View {
        ZStack {
            // Front of card (Problem)
            if !isFlipped {
                problemCard
                    .opacity(isFlipped ? 0 : 1)
                    .rotation3DEffect(
                        .degrees(isFlipped ? 90 : 0),
                        axis: (x: 0, y: 1, z: 0)
                    )
            } else {
                // Back of card (Solution)
                solutionCard
                    .opacity(isFlipped ? 1 : 0)
                    .rotation3DEffect(
                        .degrees(isFlipped ? 0 : -90),
                        axis: (x: 0, y: 1, z: 0)
                    )
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.6)) {
                isFlipped.toggle()
            }
        }
    }
    
    private var problemCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack {
                Text(problem.difficulty.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(problem.difficulty.color.opacity(0.2))
                    .foregroundColor(problem.difficulty.color)
                    .cornerRadius(12)
                
                Spacer()
                
                Text("Problem")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Problem Description
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(mockProblemDescription)
                        .font(.body)
                        .foregroundColor(.primary)
                    
                    // Example
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Example:")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Input: [2,7,11,15], target = 9")
                                .font(.system(.body, design: .monospaced))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                            
                            Text("Output: [0,1]")
                                .font(.system(.body, design: .monospaced))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                        }
                    }
                }
            }
        }
        .padding(24)
    }
    
    private var solutionCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack {
                
                Spacer()
                
                Text("Solution")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Solution Content
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Approach
                    Text("Use a hash map to store numbers we've seen and their indices. For each number, check if its complement (target - current) exists in the map.")
                        .font(.body)
                        .foregroundColor(.primary)
                    
                    // Complexity
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Time:")
                                .fontWeight(.semibold)
                            Text("O(n)")
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(.green)
                        }
                        
                        HStack {
                            Text("Space:")
                                .fontWeight(.semibold)
                            Text("O(n)")
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(.blue)
                        }
                    }
                    .font(.caption)
                    
                    // Code snippet
                    Text("class Solution:\n    def twoSum(self, nums: List[int]) -> bool:\n        seen = {}\n        for i, num in enumerate(nums):\n            complement = target - num\n            if complement in seen:\n                return [seen[complement], i]\n            seen[num] = i")
                        .font(.system(.caption2, design: .monospaced))
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
            }
            
            // Flip instruction
            HStack {
                Spacer()
                Text("tap to flip")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                Spacer()
            }
        }
        .padding(24)
    }
    

    private var actionButtons: some View {
        VStack(spacing: 16) {
            // Practice Coding Button
            Button(action: {
                showingCodingView = true
            }) {
                HStack {
                    Image(systemName: "code")
                    Text("Practice")
                }
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.blue)
                .cornerRadius(12)
            }
            
            // Status buttons (Secondary actions)
            HStack(spacing: 40) {
                // Red X button
                Button(action: {
                    print("Marked incorrect")
                    updateProblemStatus(.attempted)
                }) {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(width: 50, height: 50)
                        .background(Color.red)
                        .clipShape(Circle())
                }
                
                // Green checkmark button
                Button(action: {
                    print("Marked correct")
                    updateProblemStatus(.completed)
                }) {
                    Image(systemName: "checkmark")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(width: 50, height: 50)
                        .background(Color.green)
                        .clipShape(Circle())
                }
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 30)
    }
    
    // Mock data
    private var mockProblemDescription: String {
        switch problem.id {
        case "two-sum":
            return "Given an array of integers nums and an integer target, return indices of the two numbers such that they add up to target. You may assume that each input would have exactly one solution, and you may not use the same element twice. You can return the answer in any order."
        default:
            return "Given an integer array nums, return true if any value appears at least twice in the array, and return false if every element is distinct."
        }
    }
    
    private func updateProblemStatus(_ newStatus: ProblemStatus) {
        currProblemStatus = newStatus
        onStatusUpdate?(problem, newStatus)
        print("Updated problem '\(problem.title)' status to: \(newStatus.rawValue)")

    }
}


// MARK: - Preview
struct ProblemDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ProblemDetailView(
            problem: Problem(
                id: "two-sum",
                title: "Two Sum",
                difficulty: .easy,
                status: .attempted
            )
        )
    }
}
