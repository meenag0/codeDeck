//
//  CategoryRepository.swift
//  codeDeck
//
//  Created by Meenakshi Gopalakrishnan on 2025-08-10.
//

import Foundation
import SQLite3

class DataManager {
    static let shared = DataManager()
    
    private var db: Connection?
    private let categories = Table("categories")
    private let problems = Table("problems")
    
    private let categoryId = Expression<String>("id")
    private let categoryName = Expression<String>("name")

}
