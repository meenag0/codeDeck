//
//  DataService.swift
//  codeDeck
//
//  Created by Meenakshi Gopalakrishnan on 2025-07-26.
//

import Foundation
import Combine


// response structure for api calls

struct apiResponse: Codable {
    let Categories: [Category]
}

// for mock data

protocol DataServiceProtocol {
    func loadCategories() -> AnyPublisher<[Category], Error>
    func updateProblemStatus(problemId: String, status: ProblemStatus) -> AnyPublisher<Void, Error>
}

class DataService: DataServiceProtocol {
    private let networkManager: NetworkManagerProtocol
        
    
    // default init -> using real NetworkManager
    init() {
        self.networkManager = NetworkManager.shared
    }
    
    // custom init -> for mock NetworkManager
    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
    }
    
    func loadCategories() -> AnyPublisher<[Category], Error> {
            return Future { promise in
                Task {
                    do {
                        // get categories from database
                        let categories = try await DatabaseManager.shared.getCategories()
                        
                        // get problems for each category
                        var categoriesWithProblems: [Category] = []
                        for category in categories {
                            let problems = try await DatabaseManager.shared.getProblems(forCategoryId: category.id)
                            let categoryWithProblems = Category(
                                id: category.id,
                                name: category.name,
                                problems: problems
                            )
                            categoriesWithProblems.append(categoryWithProblems)
                        }
                        
                        promise(.success(categoriesWithProblems))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
            .receive(on: DispatchQueue.main)  
            .eraseToAnyPublisher()
    }
        
    func updateProblemStatus(problemId: String, status: ProblemStatus) -> AnyPublisher<Void, Error> {
            return Future { promise in
                Task {
                    do {
                        try await DatabaseManager.shared.updateProblemStatus(
                            problemId: problemId,
                            newStatus: status
                        )
                        promise(.success(()))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
        }
}

