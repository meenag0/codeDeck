//
//  LoadingView.swift
//  codeDeck
//
//  Created by Meenakshi Gopalakrishnan on 2025-07-26.
//

import SwiftUI

struct LoadingView: View {
    
    let message: String
    
    init(_ message: String = "Loading") {
        self.message = message
    }
    
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text(message)
                .font(.body)                    
                .foregroundColor(.secondary) 
        }
    }
}
