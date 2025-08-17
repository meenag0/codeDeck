//
//  codeDeckApp.swift
//  codeDeck
//
//  Created by Meenakshi Gopalakrishnan on 2025-07-13.
//

import SwiftUI

@main
struct codeDeckApp: App {
    
    init() {
        // Initialize database on app launch
        Task {
            await DatabaseManager.shared.setup()
        }
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
