//
//  EditTransactionView.swift
//  PennyWise
//
//  Created by Kritika Mehra on 17/11/25.
//

import SwiftUI
import SwiftData

struct EditTransactionView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var transaction: Transaction
    @State var viewModel = EditTransactionViewModel()
    
    @Query(sort: \Category.name) private var categories: [Category]
    
    var body: some View {
        NavigationStack {
            Form {
                
                // MARK: Amount
                Section("Amount") {
                    TextField("Enter amount", text: $viewModel.amountText)
                        .keyboardType(.decimalPad)
                }
                
                // MARK: Type
                Section("Type") {
                    Picker("Type", selection: $viewModel.type) {
                        Text("Income").tag("Income")
                        Text("Expense").tag("Expense")
                    }
                    .pickerStyle(.segmented)
                }
                
                // MARK: Category
                if viewModel.type == "Expense" {
                    Section("Category") {
                        Picker("Category", selection: $viewModel.selectedCategory) {
                            ForEach(categories) { category in
                                Text(category.name).tag(Optional(category))
                            }
                        }
                    }
                }
                
                // MARK: Date
                Section("Date") {
                    DatePicker("Select Date", selection: $viewModel.date, displayedComponents: .date)
                }
                
                // MARK: Note
                Section("Note") {
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
                    Button("Save") { save() }
                }
            }
            .onAppear {
                viewModel.load(from: transaction)
            }
        }
    }
    
    // MARK: Save Function
    private func save() {
        viewModel.apply(to: transaction)
        try? context.save()
        dismiss()
    }
}
