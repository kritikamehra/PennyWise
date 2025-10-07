//
//  TransactionsModel.swift
//  PennyWise
//
//  Created by Kritika Mehra on 04/10/25.
//

import SwiftData
import Foundation

@Model
class Transaction {
    var amount: Double
    var type: String // income or expense
    var date: Date
    var note: String
    var category: Category?
    
    init(amount: Double, type: String, date: Date, note: String, category: Category? = nil) {
        self.amount = amount
        self.type = type
        self.date = date
        self.note = note
        self.category = category
    }
}
