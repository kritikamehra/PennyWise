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
    var amountText: String = ""
    var type: String = "Expense"
    var selectedCategory: Category?
    var date: Date = Date()
    var note: String = ""
    
    // Load values from the SwiftData object
    func load(from transaction: Transaction) {
        amountText = String(transaction.amount)
        type = transaction.type
        selectedCategory = transaction.category
        date = transaction.date
        note = transaction.note
    }
    
    // Apply changes back into SwiftData model
    func apply(to transaction: Transaction) {
        transaction.amount = Double(amountText) ?? transaction.amount
        transaction.type = type
        transaction.category = selectedCategory
        transaction.date = date
        transaction.note = note
    }
}
