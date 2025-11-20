//
//  ContentView.swift
//  PennyWise
//
//  Created by Kritika Mehra on 04/10/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "list.bullet")
                }
            AddNewTransactionView()
                .tabItem {
                    Label("Add", systemImage: "plus.circle")
                }
            NavigationStack {
                MonthlySummaryView()
            }
            .tabItem {
                Label("Summary", systemImage: "chart.pie.fill")
            }
        }
    }
}

#Preview {
    ContentView()
}
