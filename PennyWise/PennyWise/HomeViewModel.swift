//
//  HomeViewModel.swift
//  PennyWise
//
//  Created by Kritika Mehra on 09/10/25.
//

import SwiftData
import SwiftUI

@MainActor
@Observable
class HomeViewModel {
    var filterType: String = "All"
    var transactions: [Transaction] = []
    
    func fetchTransactions(context: ModelContext) {
        let descriptor = FetchDescriptor<Transaction>(sortBy:  [SortDescriptor(\.date, order: .reverse)])
        transactions = (try? context.fetch(descriptor)) ?? []
    }
    
    var filteredTransactions: [Transaction] {
        if filterType == "All" {
                   return transactions
               } else {
                   return transactions.filter { $0.type == filterType }
               }
    }
    
    func deleteTransaction(transaction: Transaction, context: ModelContext) {
            context.delete(transaction)
        try? context.save()
        fetchTransactions(context: context)
    }
}
