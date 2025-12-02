//
//  MonthlySummaryViewModel.swift
//  PennyWise
//
//  Created by Kritika Mehra on 05/11/25.
//

import Foundation
import SwiftData

@Observable
class MonthlySummaryViewModel {
    
    // Selected Month (0–11)
    var selectedMonthIndex: Int = Calendar.current.component(.month, from: Date()) - 1
    
    // Data
    var monthlyTransactions: [Transaction] = []
    var totalIncome: Double = 0
    var totalExpense: Double = 0
    var savings: Double { totalIncome - totalExpense }
    var expenseCategoryTotals: [(category: String, amount: Double)] = []
    
    struct MonthData {
        let month: String
        let total: Double
    }
    var lastSixMonthsData: [MonthData] = []
    
    
    // MARK: - Main Update Function
    func update(context: ModelContext) {
        let allTransactions = (try? context.fetch(FetchDescriptor<Transaction>())) ?? []
        
        let selectedMonth = selectedMonthIndex + 1
        let selectedYear = Calendar.current.component(.year, from: Date())
        
        // Filter selected month
        monthlyTransactions = allTransactions.filter {
            let comps = Calendar.current.dateComponents([.month, .year], from: $0.date)
            return comps.month == selectedMonth && comps.year == selectedYear
        }
        
        // Income
        totalIncome = monthlyTransactions
            .filter { $0.type == "Income" }
            .map(\.amount)
            .reduce(0, +)
        
        // Expense
        totalExpense = monthlyTransactions
            .filter { $0.type == "Expense" }
            .map(\.amount)
            .reduce(0, +)
        
        
        // MARK: - Expense Breakdown (Expenses ONLY)
        let expensesOnly = monthlyTransactions.filter { $0.type == "Expense" }
        
        let grouped = Dictionary(grouping: expensesOnly) {
            $0.category.name
        }
        
        expenseCategoryTotals = grouped.map { (categoryName, items) in
            (
                category: categoryName,
                amount: items.reduce(0) { $0 + $1.amount }
            )
        }
        .sorted { $0.amount > $1.amount }
        
        
        // MARK: - Last 6 Month history chart
        lastSixMonthsData = generateLastSixMonths(from: allTransactions)
    }
    
    
    // MARK: - Chart Helper Function
    private func generateLastSixMonths(from all: [Transaction]) -> [MonthData] {
        var result: [MonthData] = []
        let calendar = Calendar.current
        
        for i in 0..<6 {
            let date = calendar.date(byAdding: .month, value: -i, to: Date())!
            let comps = calendar.dateComponents([.month, .year], from: date)
            let month = comps.month!
            let year = comps.year!
            
            let monthName = calendar.monthSymbols[month - 1]
            
            let monthTotal = all.filter {
                let d = calendar.dateComponents([.month, .year], from: $0.date)
                return d.month == month && d.year == year && $0.type == "Expense"
            }
                .map(\.amount)
                .reduce(0, +)
            
            result.append(MonthData(month: monthName, total: monthTotal))
        }
        
        return result.reversed()
    }
}
