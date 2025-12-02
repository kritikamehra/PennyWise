//
//  HomeView.swift
//  PennyWise
//
//  Created by Kritika Mehra on 05/10/25.
//

import SwiftUI
import SwiftData

struct AddNewTransactionView: View {
    
    @Environment(\.modelContext) var context
    @Query(sort: \Category.name) private var categories: [Category] //fetch existing categories
    @State private var viewModel = AddNewTransactionViewModel()
    
    @State private var amount: String = ""
    @State private var type: String = "Expense" // default to Expense to match common flow
    @State private var date: Date = Date()
    @State private var note: String = ""
    @State private var selectedCategory: Category?
    @State private var newCategoryName: String = ""
    
    // Filter categories by selected type
    private var filteredCategories: [Category] {
        categories.filter { $0.type.rawValue == type }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Details"){
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                    
                    Picker("Type", selection: $type) {
                        Text("Income").tag("Income")
                        Text("Expense").tag("Expense")
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: type) { _ in
                        // When type changes, auto-select first matching category (if any)
                        if let first = filteredCategories.first {
                            selectedCategory = first
                        } else {
                            selectedCategory = nil
                            viewModel.alertMessage = "No \(type.lowercased()) categories yet. Tap Manage Categories to add one."
                            viewModel.showAlert = true
                        }
                    }
                    
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    
                    TextField("Note", text: $note)
                }
                
                Section("Category") {
                    if filteredCategories.isEmpty {
                        Text("No \(type.lowercased()) categories available")
                            .foregroundColor(.gray)
                    } else {
                        Picker("Select Category", selection: $selectedCategory) {
                            ForEach(filteredCategories) { category in
                                Text(category.name).tag(Optional(category))
                            }
                        }
                    }
                    
                    NavigationLink("Manage Categories") {
                        ManageCategoriesView()
                            .modelContext(context)
                    }
                    .foregroundColor(.blue)
                }
                
                Button("Save Transaction") {
                    guard let category = selectedCategory else {
                        viewModel.alertMessage = "Please select a category"
                        viewModel.showAlert = true
                        return
                    }

                    let success = viewModel.saveTransaction(
                        amount: amount,
                        type: type,
                        date: date,
                        note: note,
                        category: category,
                        context: context
                    )

                    if success {
                        amount = ""
                        note = ""
                        // Keep type as selected; re-derive category based on current type
                        selectedCategory = filteredCategories.first
                        date = Date()
                    }
                }
                .disabled(amount.isEmpty || selectedCategory == nil)
                .alert(viewModel.alertMessage, isPresented: $viewModel.showAlert) {
                    Button("Ok", role: .cancel) {}
                }
            }
            .navigationTitle("Add new Transaction")
            .onAppear {
                // Initialize selection based on default type
                if let first = filteredCategories.first {
                    selectedCategory = first
                } else if categories.isEmpty {
                    viewModel.alertMessage = "Please add categories first"
                    viewModel.showAlert = true
                } else {
                    viewModel.alertMessage = "No \(type.lowercased()) categories yet. Tap Manage Categories to add one."
                    viewModel.showAlert = true
                }
            }
            .onChange(of: categories) { _ in
                // If categories change (e.g., after managing), ensure selection is valid
                if !filteredCategories.contains(where: { $0 == selectedCategory }) {
                    selectedCategory = filteredCategories.first
                }
            }
        }
    }
}

#Preview {
    AddNewTransactionView()
}
