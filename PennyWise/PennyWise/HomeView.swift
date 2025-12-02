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
    @State private var selectedTransaction: Transaction?
    @State private var showEditSheet = false
    
    
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
                            HStack(spacing: 14) {
                                
                                // MARK: - Leading Icon
                                ZStack {
                                    Circle()
                                        .fill((transaction.type == "Income" ? Color.green : Color.red).opacity(0.15))
                                        .frame(width: 46, height: 46)
                                    
                                    Image(systemName: transaction.type == "Income" ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                                        .symbolRenderingMode(.palette)
                                        .foregroundStyle(
                                            (transaction.type == "Income" ? Color.green.opacity(0.9) : Color.red.opacity(0.9)),
                                            .white
                                        )
                                        .font(.system(size: 26, weight: .semibold))
                                        .shadow(color: .black.opacity(0.15), radius: 1, x: 0, y: 1)
                                }
                                
                                
                                // MARK: - MAIN TEXT
                                VStack(alignment: .leading, spacing: 2) {
                                    
                                    // TITLE: CATEGORY
                                    Text(transaction.category.name)
                                        .font(.headline)
                                    
                                    // SUBTITLE: NOTE + DATE
                                    VStack(alignment: .leading, spacing: 6) {
                                        if !transaction.note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                            Text(transaction.note)
                                                .foregroundColor(.gray)
                                        }
                                        
                                        Text(transaction.date, style: .date)
                                            .foregroundColor(.gray)
                                    }
                                    .font(.caption)
                                }
                                
                                Spacer()
                                
                                // MARK: - Amount
                                Text("₹\(transaction.amount, specifier: "%.2f")")
                                    .font(.headline)
                                    .bold()
                                    .foregroundColor(transaction.type == "Income" ? .green : .red)
                            }
                            .contentShape(Rectangle())  // makes entire row tappable
                            .background(Color(.systemBackground))
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                
                                Button(role: .destructive) {
                                    viewModel.deleteTransaction(transaction: transaction, context: context)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                
                                Button {
                                    selectedTransaction = transaction
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                                .tint(.blue)
                            }
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                let tx = viewModel.filteredTransactions[index]
                                viewModel.deleteTransaction(transaction: tx, context: context)
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
            .onChange(of: viewModel.filterType) { _ in
                viewModel.fetchTransactions(context: context)
            }
            .sheet(item: $selectedTransaction, onDismiss: {
                viewModel.fetchTransactions(context: context)
            }) { tx in
                EditTransactionView(transaction: tx)
            }
            
            
        }
    }
}

//#Preview {
//    // create model container for preview
//    let container = try! ModelContainer(for: Transaction.self, Category.self)
//    let context = container.mainContext
//    
//    //add sample data
//    let sampleCategory = Category(name: "Food")
//    context.insert(sampleCategory)
//    
//    let sampleTransaction1 = Transaction(amount: 100, type: "Expense", date: Date(), note: "Lunch", category: sampleCategory)
//    let sampleTransaction2 = Transaction(amount: 500, type: "Income", date: Date(), note: "Salary", category: sampleCategory)
//    
//    context.insert(sampleTransaction1)
//    context.insert(sampleTransaction2)
//    try? context.save()
//    
//    // 3️⃣ Create the View with environment
//    return HomeView()
//        .modelContainer(container)
//}
