//
//  HomeViewModel.swift
//  PennyWise
//
//  Created by Kritika Mehra on 09/10/25.
//

import SwiftData
import SwiftUI

enum TransactionTypeFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case income = "Income"
    case expense = "Expense"
    
    var id: String { rawValue }
}

enum TransactionDateRange: String, CaseIterable, Identifiable {
    case thisMonth = "This Month"
    case lastMonth = "Last Month"
    case thisYear = "This Year"
    case custom = "Custom Range"
    
    var id: String { rawValue }
}

@MainActor
@Observable
class HomeViewModel {
    
    var selectedType: TransactionTypeFilter = .all
    var selectedDateRange: TransactionDateRange = .thisMonth
    var selectedCategory: Category? = nil
    var transactions: [Transaction] = []
    var categories: [Category] = []
    
    var customStartDate: Date = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
    var customEndDate: Date = Date()
    
    func loadData(context: ModelContext) {
        fetchTransactions(context: context)
        fetchCategories(context: context)
    }
    
    func fetchCategories(context: ModelContext) {
        let descriptor = FetchDescriptor<Category>(sortBy: [SortDescriptor(\.name)])
        categories = (try? context.fetch(descriptor)) ?? []
    }
    
    func fetchTransactions(context: ModelContext) {
        let descriptor = FetchDescriptor<Transaction>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        transactions = (try? context.fetch(descriptor)) ?? []
    }
    
    /// Final filtered output
    var filteredTransactions: [Transaction] {
        var result = transactions
        
        // Filter by type
        switch selectedType {
        case .all: break
        case .income:
            result = result.filter { $0.type == "Income" }
        case .expense:
            result = result.filter { $0.type == "Expense" }
        }
        
        // Filter by category (use id match)
        if let category = selectedCategory {
            result = result.filter { $0.category.id == category.id }
        }
        
        // Filter by date
        let now = Date()
        let calendar = Calendar.current
        
        switch selectedDateRange {
        case .thisMonth:
            result = result.filter { calendar.isDate($0.date, equalTo: now, toGranularity: .month) }
            
        case .lastMonth:
            let lastMonth = calendar.date(byAdding: .month, value: -1, to: now)!
            result = result.filter { calendar.isDate($0.date, equalTo: lastMonth, toGranularity: .month) }
            
        case .thisYear:
            result = result.filter { calendar.isDate($0.date, equalTo: now, toGranularity: .year) }
            
        case .custom:
            result = result.filter { $0.date >= customStartDate && $0.date <= customEndDate }
        }
        
        return result
    }
    
    func deleteTransaction(transaction: Transaction, context: ModelContext) {
        context.delete(transaction)
        try? context.save()
        fetchTransactions(context: context)
    }
}

