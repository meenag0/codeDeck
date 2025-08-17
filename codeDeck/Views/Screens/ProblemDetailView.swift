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
            
            // status
            if let status = problem.status {
                Image(systemName: status.icon)
                    .foregroundColor(status.color)
                    .font(.title2)
            } else {
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
            // front of card (Problem)
            if !isFlipped {
                problemCard
                    .opacity(isFlipped ? 0 : 1)
                    .rotation3DEffect(
                        .degrees(isFlipped ? 90 : 0),
                        axis: (x: 0, y: 1, z: 0)
                    )
            } else {
                // back of card (Solution)
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
            // header
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
            
            // problem Description
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(problem.description ?? "No description available")
                        .font(.body)
                        .foregroundColor(.primary)
                    
                    // Example
                    if let example = problem.example, !example.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Example:")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            
                            Text(example)
                                .font(.system(.body, design: .monospaced))
                                .padding(.horizontal, 12)
                                .fixedSize(horizontal: false, vertical: true)
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
            // header
            HStack {
                
                Spacer()
                
                Text("Solution")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            // solution Content
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // approach
                    if let solution = problem.solution, !solution.isEmpty {
                        Text(solution)
                            .font(.body)
                            .foregroundColor(.primary)
                    } else {
                        Text("No solution available")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }

                    
                    // complexity
                    VStack(alignment: .leading, spacing: 8) {
                        if let timeComplexity = problem.timeComplexity, !timeComplexity.isEmpty {
                            HStack {
                                Text("Time:")
                                    .fontWeight(.semibold)
                                Text(timeComplexity)
                                    .font(.system(.body, design: .monospaced))
                                    .foregroundColor(.green)
                            }
                        }
                        
                        if let spaceComplexity = problem.spaceComplexity, !spaceComplexity.isEmpty {
                            HStack {
                                Text("Space:")
                                    .fontWeight(.semibold)
                                Text(spaceComplexity)
                                    .font(.system(.body, design: .monospaced))
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .font(.caption)
                    

                }
            }
            
            // flip instruction
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
            // practice coding button
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
            
            // status buttons (secondary actions)
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
                
                // green checkmark button
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
