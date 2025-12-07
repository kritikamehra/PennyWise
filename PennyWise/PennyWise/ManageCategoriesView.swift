//
//  ManageCategoriesView.swift
//  PennyWise
//
//  Created by Kritika Mehra on 07/10/25.
//

import SwiftUI
import SwiftData

struct ManageCategoriesView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = ManageCategoriesViewModel()
    @State private var showAddCategorySheet = false
    @State private var showOutcomeAlert = false
    @State private var outcomeAlertMessage = ""
    @State private var lastAddWasSuccess = false

    var body: some View {
        NavigationStack {
            List {
                // MARK: Income Section
                Section(header:  SectionHeader("Income Categories", icon: "arrow.up.circle")) {
                    let incomeCategories = viewModel.categories.filter { $0.type == .income }
                    
                    if incomeCategories.isEmpty {
                        Text("No income categories yet")
                            .foregroundColor(.gray)
                            .font(.callout)
                            .padding(.vertical, 4)
                    } else {
                        ForEach(incomeCategories) { category in
                            Text(category.name)
                                .font(.body)
                        }
                        .onDelete { indexSet in
                            deleteCategory(type: .income, indexSet: indexSet)
                        }
                    }
                }
                
                // MARK: Expense Section
                Section(header:  SectionHeader("Expense Categories", icon: "arrow.down.circle")) {
                    let expenseCategories = viewModel.categories.filter { $0.type == .expense }
                    
                    if expenseCategories.isEmpty {
                        Text("No expense categories yet")
                            .foregroundColor(.gray)
                            .font(.callout)
                            .padding(.vertical, 4)
                    } else {
                        ForEach(expenseCategories) { category in
                            Text(category.name)
                                .font(.body)
                        }
                        .onDelete { indexSet in
                            deleteCategory(type: .expense, indexSet: indexSet)
                        }
                    }
                }
            }
            .navigationTitle("Manage Categories")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddCategorySheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .symbolRenderingMode(.hierarchical)
                    }
                }
            }
            .onAppear {
                viewModel.fetchCategories(from: context)
            }
            .sheet(isPresented: $showAddCategorySheet) {
                addCategorySheet
            }
            .alert(outcomeAlertMessage, isPresented: $showOutcomeAlert) {
                Button("OK", role: .cancel) {
                    if lastAddWasSuccess {
                        // Ensure fields are clean and dismiss after acknowledging success
                        viewModel.resetFields()
                        dismissSheet()
                        lastAddWasSuccess = false
                    }
                }
            }
        }
    }
    
    // MARK: Delete Category
    func deleteCategory(type: CategoryType, indexSet: IndexSet) {
        let filtered = viewModel.categories.filter { $0.type == type }
        indexSet.forEach { index in
            let category = filtered[index]
            viewModel.deleteCategory(category, context: context)
        }
    }
}

// MARK: Add Category Sheet
extension ManageCategoriesView {
    var addCategorySheet: some View {
        NavigationStack {
            Form {
                Section(header: SectionHeader("Category Name", icon: "tag")) {
                    TextField("Enter name", text: $viewModel.newCategoryName)
                }
                
                Section(header: SectionHeader("Category Type", icon: "square.grid.2x2")) {
                    Picker("Category Type", selection: $viewModel.selectedType) {
                        Text("Income").tag(CategoryType.income)
                        Text("Expense").tag(CategoryType.expense)
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle("New Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewModel.resetFields()
                        dismissSheet()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        switch viewModel.addCategory(context: context) {
                        case .success:
                            // Immediately clear the form so it is clean if reopened,
                            // then show success alert and dismiss after OK.
                            viewModel.resetFields()
                            outcomeAlertMessage = "Category added successfully."
                            lastAddWasSuccess = true
                            showOutcomeAlert = true
                        case .duplicate:
                            viewModel.resetFields()
                            outcomeAlertMessage = "Category already exists."
                            lastAddWasSuccess = false
                            showOutcomeAlert = true
                        case .saveError(let message):
                            outcomeAlertMessage = "Failed to save category: \(message)"
                            lastAddWasSuccess = false
                            showOutcomeAlert = true
                        }
                    }
                    .disabled(viewModel.newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    func dismissSheet() {
        showAddCategorySheet = false
    }
}
