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
    @State private var viewModel = ManageCategoriesViewModel()
    @State private var showAddCategorySheet = false
    @State private var alreadyExistsAlert = false
    
    var body: some View {
        NavigationStack {
            List {
                // MARK: Income Section
                Section("Income Categories") {
                    let incomeCategories = viewModel.categories.filter { $0.type == .income }
                    
                    if incomeCategories.isEmpty {
                        Text("No income categories yet")
                            .foregroundColor(.gray)
                    }
                    
                    ForEach(incomeCategories) { category in
                        Text(category.name)
                    }
                    .onDelete { indexSet in
                        deleteCategory(type: .income, indexSet: indexSet)
                    }
                }
                
                // MARK: Expense Section
                Section("Expense Categories") {
                    let expenseCategories = viewModel.categories.filter { $0.type == .expense }
                    
                    if expenseCategories.isEmpty {
                        Text("No expense categories yet")
                            .foregroundColor(.gray)
                    }
                    
                    ForEach(expenseCategories) { category in
                        Text(category.name)
                    }
                    .onDelete { indexSet in
                        deleteCategory(type: .expense, indexSet: indexSet)
                    }
                }
            }
            .navigationTitle("Manage Categories")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddCategorySheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .onAppear {
                viewModel.fetchCategories(from: context)
            }
            .sheet(isPresented: $showAddCategorySheet) {
                addCategorySheet
            }
            .alert("Category already exists", isPresented: $alreadyExistsAlert) {
                Button("OK", role: .cancel) {}
            }
        }
    }
    
    // MARK: Delete
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
                TextField("Category Name", text: $viewModel.newCategoryName)
                
                Picker("Category Type", selection: $viewModel.selectedType) {
                    Text("Income").tag(CategoryType.income)
                    Text("Expense").tag(CategoryType.expense)
                }
                .pickerStyle(.segmented)
            }
            .navigationTitle("New Category")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewModel.resetFields()
                        dismissSheet()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        if !viewModel.addCategory(context: context) {
                            alreadyExistsAlert = true
                        } else {
                            dismissSheet()
                        }
                    }
                }
            }
        }
    }
    
    func dismissSheet() {
        showAddCategorySheet = false
    }
}
