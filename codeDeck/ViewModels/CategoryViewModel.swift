//
//  CategoryViewModel.swift
//  codeDeck
//
//  Created by Meenakshi Gopalakrishnan on 2025-07-27.
//

import Foundation
import Combine
import SQLite

@MainActor
class CategoryViewModel: ObservableObject {
    
    // published properties automatically update the UI when changed
    @Published var categories: [Category] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let db = DatabaseManager.shared
    
    func loadCategories() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let dbCategories = try await db.getCategories()   // fetch categories
            
            // fetch problems for each category
            
            var fullCategories: [Category] = []
            for category in dbCategories {
                let problems = try await db.getProblems(forCategoryId: category.id)
                fullCategories.append(
                    Category(
                        id: category.id,
                        name: category.name,
                        problems: problems
                    )
                )
            }
            
            categories = fullCategories
            isLoading = false
            
        } catch {
            errorMessage = "Failed to load categories: \(error.localizedDescription)"
            isLoading = false
        }
    }

    func updateProblemStatus(problemId: String, newStatus: ProblemStatus) async {
        try? await DatabaseManager.shared.updateProblemStatus(problemId: problemId, newStatus: newStatus)

        // update local categories array
        for catIndex in categories.indices {
            if let probIndex = categories[catIndex].problems.firstIndex(where: { $0.id == problemId }) {
                categories[catIndex].problems[probIndex].status = newStatus
            }
        }
    }

    
    func filteredCategories(searchText: String) -> [Category] {
        
        if searchText.isEmpty {
            return categories
        }
        
        return categories.filter { category in
            category.name.localizedCaseInsensitiveContains(searchText) ||
            category.problems.contains { problem in
                problem.title.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    // Add this function to your CategoryViewModel class:

    func filteredCategories(
        searchText: String,
        selectedDifficulties: Set<Difficulty>,
        selectedStatuses: Set<ProblemStatus>
    ) -> [Category] {
        
        var filteredCategories = categories
        
        // Apply search filter
        if !searchText.isEmpty {
            filteredCategories = filteredCategories.filter { category in
                category.name.localizedCaseInsensitiveContains(searchText) ||
                category.problems.contains { problem in
                    problem.title.localizedCaseInsensitiveContains(searchText)
                }
            }
        }
        
        // Apply difficulty and status filters
        if !selectedDifficulties.isEmpty || !selectedStatuses.isEmpty {
            filteredCategories = filteredCategories.compactMap { category in
                let filteredProblems = category.problems.filter { problem in
                    let matchesDifficulty = selectedDifficulties.isEmpty || selectedDifficulties.contains(problem.difficulty)
                    let matchesStatus = selectedStatuses.isEmpty || (problem.status != nil && selectedStatuses.contains(problem.status!))
                    
                    return matchesDifficulty && matchesStatus
                }
                
                // If no problems match the filter, don't show the category
                if filteredProblems.isEmpty {
                    return nil
                }
                
                // Return category with filtered problems
                return Category(
                    id: category.id,
                    name: category.name,
                    problems: filteredProblems
                )
            }
        }
        
        return filteredCategories
    }
    
}
