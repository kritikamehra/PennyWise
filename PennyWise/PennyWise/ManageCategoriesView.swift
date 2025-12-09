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
    @FocusState private var isFocused: Bool

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
                                .swipeActions(edge: .leading) {
                                    Button {
                                        viewModel.editingCategory = category
                                        viewModel.showEditSheet = true
                                    } label: {
                                        Label("Edit", systemImage: "pencil")
                                    }
                                    .tint(.blue)
                                }
                                .swipeActions {
                                    Button(role: .destructive) {
                                        viewModel.deleteCategory(category, context: context)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
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
                                .swipeActions(edge: .leading) {
                                    Button {
                                        viewModel.editingCategory = category
                                        viewModel.showEditSheet = true
                                    } label: {
                                        Label("Edit", systemImage: "pencil")
                                    }
                                    .tint(.blue)
                                }
                                .swipeActions {
                                    Button(role: .destructive) {
                                        viewModel.deleteCategory(category, context: context)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    }
                }
            }
            .sheet(isPresented: $viewModel.showEditSheet) {
                EditCategorySheet(
                    category: viewModel.editingCategory,
                    onSave: { name, type in
                        viewModel.updateCategory(
                            category: viewModel.editingCategory,
                            name: name,
                            type: type,
                            context: context
                        )
                    }
                )
            }
            .navigationTitle("Manage Categories")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isFocused = false
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
            .onChange(of: showAddCategorySheet) { isPresented in
                if !isPresented {
                    // Ensure keyboard is down when the sheet closes
                    isFocused = false
                }
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
                        .focused($isFocused)
                        .submitLabel(.done)
                        .onSubmit {
                            isFocused = false
                        }
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
                        isFocused = false
                        viewModel.resetFields()
                        dismissSheet()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        isFocused = false
                        switch viewModel.addCategory(context: context) {
                        case .success:
                            viewModel.resetFields()
                            outcomeAlertMessage = "Category added successfully."
                            lastAddWasSuccess = true
                            showOutcomeAlert = true
                        case .duplicate:
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
        isFocused = false
        showAddCategorySheet = false
    }
}
