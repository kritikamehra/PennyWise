//
//  ManageCategoriesViewModel.swift
//  PennyWise
//
//  Created by Kritika Mehra on 14/10/25.
//

import SwiftData
import SwiftUI

enum AddCategoryOutcome {
    case success
    //    case emptyName    // case can't be reached as button is disabled
    case duplicate
    case saveError(String)
}

@MainActor
@Observable
class ManageCategoriesViewModel {
    
    // MARK: - Properties
    var newCategoryName: String = ""
    var selectedType: CategoryType = .expense     // default type
    var categories: [Category] = []
    var showEditSheet: Bool = false
    
    // Used by ManageCategoriesView when opening the edit sheet
    var editingCategory: Category?
    
    // Alert state for edit/update flows
    var alertMessage: String = ""
    var showAlert: Bool = false
    
    // MARK: - Init
    init() {}
    
    // MARK: - Fetch
    func fetchCategories(from context: ModelContext) {
        let descriptor = FetchDescriptor<Category>(
            sortBy: [SortDescriptor(\.name)]
        )
        categories = (try? context.fetch(descriptor)) ?? []
    }
    
    // MARK: - Add Category
    func addCategory(context: ModelContext) -> AddCategoryOutcome {
        print("➡️ Add tapped. Name: \(newCategoryName), Type: \(selectedType.rawValue)")
        print("Store config:", context.container.configurations)

        let trimmedName = newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines)
//         Already disabled button to case can't be reached
//        guard !trimmedName.isEmpty else {
//            print("❌ Empty name")
//            return .emptyName
//        }

        if categories.contains(where: { $0.name.lowercased() == trimmedName.lowercased() && $0.type == selectedType }) {
            print("❌ Duplicate category")
            return .duplicate
        }

        let newCategory = Category(name: trimmedName, type: selectedType)
        context.insert(newCategory)
        print("📌 Inserted:", newCategory)

        do {
            try context.save()
            print("💾 Saved to context")
            fetchCategories(from: context)
            let all = try context.fetch(FetchDescriptor<Category>())
            print("🔥 ALL CATEGORIES IN DB:", all)
            print("📥 After fetch:", categories)
            newCategoryName = ""
            selectedType = .expense
            return .success
        } catch {
            print("🔥 Error saving category:", error.localizedDescription)
            return .saveError(error.localizedDescription)
        }
    }

    
    // MARK: - Delete
    func deleteCategory(_ category: Category, context: ModelContext) {
        context.delete(category)
        
        do {
            try context.save()
            fetchCategories(from: context)
        } catch {
            print("Error deleting category: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Update
    func updateCategory(category: Category?, name: String, type: CategoryType, context: ModelContext) {
        guard let category else { return }
        
        let cleanedLower = name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        // Prevent duplicate (same name + type, different object)
        if categories.contains(where: {
            $0 !== category &&
            $0.name.lowercased() == cleanedLower &&
            $0.type == type
        }) {
            alertMessage = "A category with the same name already exists."
            showAlert = true
            return
        }
        
        // Normal update
        category.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        category.type = type
        do {
            try context.save()
            fetchCategories(from: context)
            alertMessage = "Category updated!"
            showAlert = true
        } catch {
            alertMessage = "Failed to update category: \(error.localizedDescription)"
            showAlert = true
        }
    }
    
    func resetFields() {
        newCategoryName = ""
        selectedType = .expense
    }
}
