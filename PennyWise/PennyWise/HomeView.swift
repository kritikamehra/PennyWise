//
//  HomeView.swift
//  PennyWise
//
//  Created by Kritika Mehra on 05/10/25.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Query(sort: \Transaction.date, order: .reverse) private var transactions: [Transaction]
    @Environment(\.modelContext) private var  context
    
    @State private var filterType: String = "All"
    
    private var filteredTransactions: [Transaction] {
        if filterType == "All"{
            return transactions
        } else {
            return transactions.filter { $0.type == filterType}
        }
    }
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading){
                Picker("Filter", selection: $filterType) {
                    Text("All").tag("All")
                    Text("Income").tag("Income")
                    Text("Expense").tag("Expense")
                }
                .pickerStyle(.segmented)
                .padding()
                
                List {
                    ForEach(filteredTransactions) { transaction in
                        VStack(alignment: .leading) {
                            Text("\(transaction.note)")
                                .font(.headline)
                            Text("\(transaction.type) - \(transaction.amount, specifier: "%.2f")")
                                .foregroundStyle(transaction.type == "Income" ? .green : .red)
                        }
                    }
                    .onDelete(perform: deleteTransaction)
                }
            }
            .navigationTitle("Transactions")
        }
    }
    
    private func deleteTransaction(indexSet: IndexSet) {
        for index in indexSet {
            context.delete(transactions[index])
        }
        try? context.save()
    }
}

#Preview {
    HomeView()
}
