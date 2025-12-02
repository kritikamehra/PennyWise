//
//  ManageCategoriesViewModel.swift
//  PennyWise
//
//  Created by Kritika Mehra on 14/10/25.
//

import SwiftData
import SwiftUI

@MainActor
@Observable
class ManageCategoriesViewModel {
    
    // MARK: - Properties
    var newCategoryName: String = ""
    var selectedType: CategoryType = .expense     // default type
    var categories: [Category] = []
    
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
    func addCategory(context: ModelContext) -> Bool {
        print("➡️ Add tapped. Name: \(newCategoryName), Type: \(selectedType.rawValue)")
        print("Store config:", context.container.configurations)


        let trimmedName = newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            print("❌ Empty name")
            return false
        }

        if categories.contains(where: { $0.name.lowercased() == trimmedName.lowercased() && $0.type == selectedType }) {
            print("❌ Duplicate category")
            return false
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
            return true
        } catch {
            print("🔥 Error saving category:", error.localizedDescription)
            return false
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
    
    func resetFields() {
        newCategoryName = ""
        selectedType = .expense
    }
}
