//
//  FilterView.swift
//  PennyWise
//
//  Created by Kritika Mehra on 06/12/25.
//

import SwiftUI

struct FiltersView: View {
    
    @Environment(\.dismiss) var dismiss
    @Bindable var viewModel: HomeViewModel
    
    var body: some View {
        NavigationStack {
            Form {
                
                // Type Filter
                Section("Transaction Type") {
                    Picker("Type", selection: $viewModel.selectedType) {
                        ForEach(TransactionTypeFilter.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                // Date Filter
                Section("Date Range") {
                    Picker("Range", selection: $viewModel.selectedDateRange) {
                        ForEach(TransactionDateRange.allCases) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                }
                
                if viewModel.selectedDateRange == .custom {
                    DatePicker("Start", selection: $viewModel.customStartDate, displayedComponents: .date)
                    DatePicker("End", selection: $viewModel.customEndDate, displayedComponents: .date)
                }
                
                // Category
                Section("Category") {
                    Picker("Category", selection: $viewModel.selectedCategory) {
                        Text("All").tag(nil as Category?)
                        ForEach(viewModel.categories) { cat in
                            Text(cat.name).tag(cat as Category?)
                        }
                    }
                }
            }
            .navigationTitle("Filters")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
