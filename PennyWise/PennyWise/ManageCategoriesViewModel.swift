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
    
    var newCategoryName: String = ""
    var categories: [Category] = []
    
    init() {}
    
    func fetchCategories(from context: ModelContext) {
        let descriptor = FetchDescriptor<Category>(sortBy: [SortDescriptor(\.name)])
        categories = (try? context.fetch(descriptor)) ?? []
    }
    
    func addCategory(context: ModelContext) -> Bool {
        let trimmedName = newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return false }
        
        if categories.contains(where: { $0.name.lowercased() == trimmedName.lowercased()}) {
            return false
        }
        
        let newCategory = Category(name: trimmedName)
                context.insert(newCategory)
                try? context.save()
                fetchCategories(from: context)
                newCategoryName = ""
                return true
    }
    
    func deleteCategory(category: Category, context: ModelContext) {
          
               context.delete(category)
           
           try? context.save()
        fetchCategories(from: context)
       }
}
