//
//  CategoryViewModel.swift
//  codeDeck
//
//  Created by Meenakshi Gopalakrishnan on 2025-07-27.
//

import Foundation
import Combine

class CategoryViewModel: ObservableObject {
    
    // Published properties automatically update the UI when changed
    @Published var categories: [Category] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let dataService = DataService()
    private var cancellables = Set<AnyCancellable>()
    
    func loadCategories() {
        isLoading = true
        errorMessage = nil
        
        dataService.loadCategories()
            .sink(
                receiveCompletion: { [weak self] completion in
                    DispatchQueue.main.async {
                        self?.isLoading = false
                        
                        if case .failure(let error) = completion {
                            self?.errorMessage = "Failed to load categories: \(error.localizedDescription)"
                        }
                    }
                },
                receiveValue: { [weak self] categories in
                    DispatchQueue.main.async {
                        self?.categories = categories
                    }
                }
            )
            .store(in: &cancellables)
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
