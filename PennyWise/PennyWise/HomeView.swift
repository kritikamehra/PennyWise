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
    @State var viewModel = HomeViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                
                // Filter Picker
                Picker("Filter", selection: $viewModel.filterType) {
                    Text("All").tag("All")
                    Text("Income").tag("Income")
                    Text("Expense").tag("Expense")
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                // Transaction List
                if viewModel.filteredTransactions.isEmpty {
                    ContentUnavailableView("No Transactions",
                                           systemImage: "tray",
                                           description: Text("Add a transaction to see it here."))
                    .padding(.top, 50)
                } else {
                    List {
                        ForEach(viewModel.filteredTransactions) { transaction in
                            HStack {
                                Image(systemName: transaction.type == "Income" ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                                    .symbolRenderingMode(.palette)
                                    .foregroundStyle(
                                        transaction.type == "Income" ? Color.green.opacity(0.8) : Color.red.opacity(0.8),
                                        .white
                                    )
                                    .font(.system(size: 26, weight: .semibold))
                                    .shadow(color: .black.opacity(0.15), radius: 2, x: 0, y: 1)
                                    .padding(6)
                                    .background(
                                        Circle()
                                            .fill(transaction.type == "Income" ? Color.green.opacity(0.15) : Color.red.opacity(0.15))
                                    )
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(transaction.category?.name ?? "")
                                        .font(.headline)
                                    Text(transaction.date, style: .date)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                Text("₹\(transaction.amount, specifier: "%.2f")")
                                    .bold()
                                    .foregroundColor(transaction.type == "Income" ? .green : .red)
                            }
                            .padding(.vertical, 6)
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                let transaction = viewModel.filteredTransactions[index]
                                viewModel.deleteTransaction(transaction: transaction, context: context)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Transactions")
            .onAppear {
                viewModel.fetchTransactions(context: context)
            }
        }
    }
}

#Preview {
    // create model container for preview
    let container = try! ModelContainer(for: Transaction.self, Category.self)
    let context = container.mainContext
    
    //add sample data
    let sampleCategory = Category(name: "Food")
    context.insert(sampleCategory)
    
    let sampleTransaction1 = Transaction(amount: 100, type: "Expense", date: Date(), note: "Lunch", category: sampleCategory)
    let sampleTransaction2 = Transaction(amount: 500, type: "Income", date: Date(), note: "Salary", category: sampleCategory)
    
    context.insert(sampleTransaction1)
    context.insert(sampleTransaction2)
    try? context.save()
    
    // 3️⃣ Create the View with environment
    return HomeView()
        .modelContainer(container)
}
