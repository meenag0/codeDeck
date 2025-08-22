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
        ZStack {
            LinearGradient(
                colors: [Color.deepBlack, Color.charcoal, Color.darkGray],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        GeometryReader { geometry in
            VStack(spacing: 0) {
                navigationBar
                flashcard
                    .frame(maxWidth: .infinity)
                    .frame(maxHeight: .infinity)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                
                
                actionButtons
                    .padding(.top, 10)
            }
            }
        }
        .preferredColorScheme(.dark)
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
                    .foregroundColor(.matrixGreen)
            }
            .buttonStyle(IconButtonStyle(color: .matrixGreen, size: 44))

            Spacer()

            VStack {
            Text(problem.title)
                .font(FontStyle.displaySmall)
                .foregroundColor(.primaryText)
                .fontWeight(.bold)
                .lineLimit(2)
                .multilineTextAlignment(.center)
            }
            Spacer()
            
            // status
            if let status = problem.status {
                VStack(spacing: 4) {
                    Image(systemName: status.modernIcon)
                        .foregroundColor(status.modernColor)
                        .font(.system(size: 20, weight: .semibold))
                    
                    Text(status.displayName)
                        .font(FontStyle.footnote)
                        .foregroundColor(status.modernColor)
                }
            } else {
                Circle()
                    .fill(Color.tertiaryText)
                    .frame(width: 8, height: 8)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
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
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.charcoal)
                .shadow(color: Color.matrixGreen.opacity(0.1), radius: 20, x: 0, y: 8)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [Color.matrixGreen.opacity(0.3), Color.matrixGreen.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
        )        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.6)) {
                isFlipped.toggle()
            }
        }
    }
    
    private var problemCard: some View {
        VStack(alignment: .leading, spacing: 24) {
            // problem description
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text(problem.description ?? "No description available")
                        .font(FontStyle.bodyLarge)
                        .foregroundColor(.primaryText)
                        .lineSpacing(4)
                    
                    // modern example section
                    if let example = problem.example, !example.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "lightbulb.fill")
                                    .foregroundColor(.matrixGreen)
                                    .font(.system(size: 16))
                                
                                Text("Example")
                                    .font(FontStyle.bodyLarge)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.matrixGreen)
                            }
                            
                            Text(example)
                                .font(FontStyle.codeMedium)
                                .foregroundColor(.primaryText)
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.darkGray)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.mediumGray, lineWidth: 1)
                                        )
                                )
                        }
                    }
                }
            }
        }
        .padding(24)
    }
    

    private var solutionCard: some View {
        VStack(alignment: .leading, spacing: 24) {
            
            // solution content
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // approach
                    if let solution = problem.solution, !solution.isEmpty {
                        Text(solution)
                            .font(FontStyle.bodyLarge)
                            .foregroundColor(.primaryText)
                            .lineSpacing(4)
                    } else {
                        Text("No solution available")
                            .font(FontStyle.bodyLarge)
                            .foregroundColor(.secondaryText)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        if let timeComplexity = problem.timeComplexity, !timeComplexity.isEmpty {
                            HStack {
                                HStack(spacing: 6) {
                                    Image(systemName: "clock.fill")
                                        .foregroundColor(.matrixGreen)
                                        .font(.system(size: 12))
                                    Text("Time:")
                                        .fontWeight(.semibold)
                                        .foregroundColor(.primaryText)
                                }
                                Text(timeComplexity)
                                    .font(FontStyle.codeMedium)
                                    .foregroundColor(.matrixGreen)
                            }
                        }
                        
                        if let spaceComplexity = problem.spaceComplexity, !spaceComplexity.isEmpty {
                            HStack {
                                HStack(spacing: 6) {
                                    Image(systemName: "memorychip.fill")
                                        .foregroundColor(.blueAccent)
                                        .font(.system(size: 12))
                                    Text("Space:")
                                        .fontWeight(.semibold)
                                        .foregroundColor(.primaryText)
                                }
                                Text(spaceComplexity)
                                    .font(FontStyle.codeMedium)
                                    .foregroundColor(.blueAccent)
                            }
                        }
                    }
                    .font(FontStyle.bodyMedium)
                }
            }
            

        }
        .padding(24)
    }

    private var actionButtons: some View {
        VStack(spacing: 20) {
            Button(action: {
                showingCodingView = true
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "code")
                        .font(.system(size: 18, weight: .semibold))
                    Text("Practice Coding")
                        .font(FontStyle.bodyLarge)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.deepBlack)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.matrixGreen)
                        .shadow(color: Color.matrixGreen.opacity(0.3), radius: 8, x: 0, y: 4)
                )
            }
            
            // status buttons
            HStack(spacing: 50) {
                // X button
                Button(action: {
                    print("Marked incorrect")
                    updateProblemStatus(.attempted)
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(
                            Circle()
                                .fill(Color.errorRed)
                                .shadow(color: Color.errorRed.opacity(0.3), radius: 8, x: 0, y: 4)
                        )
                }
                
                Button(action: {
                    print("Marked correct")
                    updateProblemStatus(.completed)
                }) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(
                            Circle()
                                .fill(Color.successGreen)
                                .shadow(color: Color.successGreen.opacity(0.3), radius: 8, x: 0, y: 4)
                        )
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 30)
    }
    
    
    private func updateProblemStatus(_ newStatus: ProblemStatus) {
        currProblemStatus = newStatus
        onStatusUpdate?(problem, newStatus)
        print("Updated problem '\(problem.title)' status to: \(newStatus.rawValue)")

    }
}

