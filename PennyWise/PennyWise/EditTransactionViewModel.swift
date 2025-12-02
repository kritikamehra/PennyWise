//
//  EditTransactionViewModel.swift
//  PennyWise
//
//  Created by Kritika Mehra on 18/11/25.
//

import SwiftData
import SwiftUI

@Observable
class EditTransactionViewModel {

    var amountText = ""
    var type: String = "Expense"
    var selectedCategory: Category?
    var date = Date()
    var note = ""

    // Filter categories based on type
    func filteredCategories(from categories: [Category]) -> [Category] {
        categories.filter { $0.type.rawValue == type }
    }

    // Auto-select category for the selected type
    func updateCategoryForType(allCategories: [Category]) {
        selectedCategory = filteredCategories(from: allCategories).first
    }

    // Form validation
    var isFormValid: Bool {
        Double(amountText) != nil && selectedCategory != nil
    }

    // Load transaction into VM
    func load(from transaction: Transaction, allCategories: [Category]) {
        amountText = String(transaction.amount)
        type = transaction.type
        selectedCategory = transaction.category
        date = transaction.date
        note = transaction.note

        /// Ensure a valid category exists for current type
        updateCategoryForType(allCategories: allCategories)
    }

    // Apply edited values back to SwiftData
    func apply(to transaction: Transaction) {
        transaction.amount = Double(amountText) ?? transaction.amount
        transaction.type = type
        transaction.category = selectedCategory! // safe to unwrap as form is disabled is nil, can also use guard and return
        transaction.date = date
        transaction.note = note
    }
}
