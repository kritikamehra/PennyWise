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
                
                // MARK: - Transaction Type
                Section(header: SectionHeader("Transaction Type", icon: "arrow.2.circlepath")) {
                    Picker("Type", selection: $viewModel.selectedType) {
                        ForEach(TransactionTypeFilter.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                // MARK: - Date Range
                Section(header: SectionHeader("Date Range", icon: "calendar")) {
                    Picker("Range", selection: $viewModel.selectedDateRange) {
                        ForEach(TransactionDateRange.allCases) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                    
                    if viewModel.selectedDateRange == .custom {
                        DatePicker("Start", selection: $viewModel.customStartDate, displayedComponents: .date)
                        DatePicker("End", selection: $viewModel.customEndDate, displayedComponents: .date)
                    }
                }
                
                // MARK: - Category
                Section(header: SectionHeader("Category", icon: "square.grid.2x2")) {
                    Picker("Category", selection: $viewModel.selectedCategory) {
                        Text("All").tag(nil as Category?)
                        ForEach(viewModel.categories) { cat in
                            Text(cat.name).tag(cat as Category?)
                        }
                    }
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
