//
//  AddNewTransactionViewModel.swift
//  PennyWise
//
//  Created by Kritika Mehra on 09/10/25.
//

import Foundation
import SwiftData

@MainActor
final class AddNewTransactionViewModel: ObservableObject {
    
    @Published var amount: String = ""
    @Published var type: String = "Expense"
    @Published var date: Date = Date()
    @Published var note: String = ""
    
    // Original selection by object (kept for convenience in the rest of the code)
    @Published var selectedCategory: Category?

    @Published var alertMessage: String = ""
    @Published var showAlert = false

    var isSaveEnabled: Bool {
        guard let num = Double(amount), num > 0 else { return false }
        guard selectedCategory != nil else { return false }
        return true
    }

    func filteredCategories(_ categories: [Category]) -> [Category] {
        categories.filter { $0.type.rawValue == type }
    }
    
    func saveTransaction(context: ModelContext) {
        
        guard let value = Double(amount), value > 0 else {
            alert("Enter a valid amount")
            return
        }
        
        guard let category = selectedCategory else {
            alert("Please select a category")
            return
        }

        let newTransaction = Transaction(amount: value, type: type, date: date, note: note, category: category)
        context.insert(newTransaction)
        try? context.save()
        
        do {
            try context.save()
            // Optional debug fetch
            let all = try context.fetch(FetchDescriptor<Transaction>())
            print("💾 Saved to context. Total transactions:", all.count)
            reset()
            alert("Transaction saved successfully")
        } catch {
            print("🔥 Error saving/fetching transactions:", error.localizedDescription)
            alert("Failed to save transaction: \(error.localizedDescription)")
        }
    }
    
    func updateSelection(categories: [Category]) {
        let filtered = filteredCategories(categories)
        
        if selectedCategory == nil {
            selectedCategory = filtered.first
        } else if !filtered.contains(selectedCategory!) {
            selectedCategory = filtered.first
        }
    }
    
    func reset() {
        amount = ""
        type = "Expense"
        date = Date()
        note = ""
        selectedCategory = nil
    }
    
    private func alert(_ text: String) {
        alertMessage = text
        showAlert = true
    }
}
