//
//  ContentView.swift
//  codeDeck
//
//  Created by Meenakshi Gopalakrishnan on 2025-07-20.
//

import SwiftUI

struct ContentView: View {
    
    @State private var searchText = ""  // watched and changes ui state based on search input
    @State private var expanded: Set<String> = []  // using set for the collapsible categories to keep track of which categories are open - best because of optimal memory usage andd fastest lookup time O(1)
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack{
                Text("Practice")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Spacer()
            }
            
            HStack{
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Search problems...", text: $searchText) // updates search bar w typed input
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
            
            Button(action: {
                // Filter
            }) {
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .foregroundColor(.green)
                    .font(.title2)
            }
            .padding(.leading, 5)
        }
            
            Spacer()
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
