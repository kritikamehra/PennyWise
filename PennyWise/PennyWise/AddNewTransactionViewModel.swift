//
//  AddNewTransactionViewModel.swift
//  PennyWise
//
//  Created by Kritika Mehra on 09/10/25.
//

import SwiftUI
import SwiftData

@Observable
class AddNewTransactionViewModel {
    var showAlert: Bool = false
    var alertMessage: String = ""
    
    @MainActor
    func saveTransaction(
        amount: String,
        type: String,
        date: Date,
        note: String,
        category: Category?,
        context: ModelContext
    ) -> Bool {
        
        guard let amt = Double(amount), amt > 0  else {
            showAlert = true
            alertMessage = "Please enter a valid amount"
            return false
        }
        
        guard !type.isEmpty else {
            alertMessage = "Please select a transaction type."
            showAlert = true
            return false
        }
        
        guard (category != nil) else {
            alertMessage = "Please select a category."
            showAlert = true
            return false
        }
        
        let newTransaction = Transaction(amount: amt, type: type, date: date, note: note, category: category)
        context.insert(newTransaction)
        try? context.save()
        
        alertMessage = "Transaction saved successfully!"
        showAlert = true
        
        return true
    }
}
