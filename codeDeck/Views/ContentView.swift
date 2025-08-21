//
//  ContentView.swift
//  codeDeck
//
//  Created by Meenakshi Gopalakrishnan on 2025-07-20.
//

import SwiftUI

struct ContentView: View {
    
    // MARK: - State Properties
    @State private var searchText = ""
    @State private var expanded: Set<String> = []
    @State private var selectedDifficulties: Set<Difficulty> = []
    @State private var selectedStatuses: Set<ProblemStatus> = []
    @State private var selectedProblem: Problem?
    @State private var navigationPath = NavigationPath()
    
    @StateObject private var viewModel = CategoryViewModel()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                LinearGradient(
                    colors: [Color.deepBlack, Color.charcoal],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
            VStack(alignment: .leading, spacing: 0) {
                headerSection
                searchSection
                contentSection
            }
            .padding(.horizontal)
            }
            .preferredColorScheme(.dark)
            .onAppear {
                Task {
                    await viewModel.loadCategories()
                }
            }

            .navigationDestination(for: Problem.self) { problem in
                ProblemDetailView(
                    problem: problem,
                    onStatusUpdate: { updatedProblem, newStatus in
                        Task {
                            await viewModel.updateProblemStatus(problemId: updatedProblem.id, newStatus: newStatus)
                        }
                    }
                )

            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack {
            Text("Practice")
                .font(FontStyle.displayLarge)
                .foregroundColor(.primaryText)
            Spacer()
        }
        .padding(.vertical)
    }
    
    // MARK: - Search Section
    private var searchSection: some View {
        HStack {
            SearchBar(
                text: $searchText,
                placeholder: "Search problems..."
            )
            
            FilterButton(
                selectedDifficulties: $selectedDifficulties,
                selectedStatuses: $selectedStatuses
            )
            .padding(.leading, 5)
        }
        .padding(.bottom)
    }
    
    // MARK: - Content Section
    private var contentSection: some View {
        Group {
            if viewModel.isLoading {
                LoadingView("Loading categories...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let errorMessage = viewModel.errorMessage {
                errorView(message: errorMessage)
            } else {
                categoriesList
            }
        }
    }
    
    // MARK: - Categories List
    private var categoriesList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(filteredCategories, id: \.id) { category in
                    CategoryView(
                        category: category,
                        isExpanded: expanded.contains(category.id),
                        onToggle: {
                            toggleCategory(category.id)
                        },
                        onProblemTap: { problem in
                            navigationPath.append(problem)

                        }
                    )
                }
            }
            .padding(.vertical, 8)
        }
    }
    
    // MARK: - Error View
    private func errorView(message: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(.warningOrange)
            
            Text("Something went wrong")
                .font(FontStyle.displaySmall)
                .foregroundColor(.primaryText)
            
            Text(message)
                .font(FontStyle.bodyMedium)
                .foregroundColor(.secondaryText)
                .multilineTextAlignment(.center)
            
            Button("Try Again") {
                Task {
                    await viewModel.loadCategories()
                }
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    // MARK: - Computed Properties
    private var filteredCategories: [Category] {
        viewModel.filteredCategories(
            searchText: searchText,
            selectedDifficulties: selectedDifficulties,
            selectedStatuses: selectedStatuses
        )
    }
    
    // MARK: - Actions
    private func toggleCategory(_ categoryId: String) {
        withAnimation(.easeInOut(duration: 0.3)) {
            if expanded.contains(categoryId) {
                expanded.remove(categoryId)
            } else {
                expanded.insert(categoryId)
            }
        }
    }
    
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
}

