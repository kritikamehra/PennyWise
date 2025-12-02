//
//  EditTransactionView.swift
//  PennyWise
//
//  Created by Kritika Mehra on 17/11/25.
//

import SwiftUI
import SwiftData

struct EditTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var transaction: Transaction
    @Query(sort: \Category.name) private var allCategories: [Category]

    @State var viewModel = EditTransactionViewModel()

    var body: some View {
        NavigationStack {
            Form {

                // MARK: - Amount
                Section(header: Text("Amount")) {
                    TextField("Enter amount", text: $viewModel.amountText)
                        .keyboardType(.decimalPad)
                }

                // MARK: - Type
                Section(header: Text("Type")) {
                    Picker("Transaction Type", selection: $viewModel.type) {
                        Text("Income").tag("Income")
                        Text("Expense").tag("Expense")
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: viewModel.type) { _ in
                        viewModel.updateCategoryForType(allCategories: allCategories)
                    }
                }

                // MARK: - Category
                Section(header: Text("Category")) {
                    let filtered = viewModel.filteredCategories(from: allCategories)

                    if filtered.isEmpty {
                        Text("No categories available")
                            .foregroundColor(.gray)
                    } else {
                        Picker("Select Category", selection: $viewModel.selectedCategory) {
                            ForEach(filtered) { category in
                                Text(category.name).tag(Optional(category))
                            }
                        }
                    }
                }

                // MARK: - Date
                Section(header: Text("Date")) {
                    DatePicker("Select Date", selection: $viewModel.date, displayedComponents: .date)
                }

                // MARK: - Note
                Section(header: Text("Note")) {
                    TextField("Optional note", text: $viewModel.note)
                }
            }
            .navigationTitle("Edit Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.apply(to: transaction)
                        dismiss()
                    }
                    .disabled(!viewModel.isFormValid)
                }
            }
            .onAppear {
                viewModel.load(from: transaction, allCategories: allCategories)
            }
        }
    }
}
