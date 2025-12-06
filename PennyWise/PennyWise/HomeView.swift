//
//  HomeView.swift
//  PennyWise
//
//  Created by Kritika Mehra on 05/10/25.
//
//
//  HomeView.swift
//  PennyWise
//

import SwiftUI
import SwiftData

struct HomeView: View {
    
    @Environment(\.modelContext) private var context
    @State var viewModel = HomeViewModel()

    @State private var showFilters = false
    @State private var selectedTransaction: Transaction?

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {

                // Quick Filter
                Picker("Filter", selection: $viewModel.selectedType) {
                    ForEach(TransactionTypeFilter.allCases) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                
                if viewModel.filteredTransactions.isEmpty {
                    ContentUnavailableView(
                        "No Transactions",
                        systemImage: "tray",
                        description: Text("Try changing your filters.")
                    )
                    .padding(.top, 50)
                } else {
                    List {
                        ForEach(viewModel.filteredTransactions) { transaction in
                            
                            HStack(spacing: 14) {
                                Circle()
                                    .fill((transaction.type == "Income" ? Color.green : Color.red).opacity(0.15))
                                    .frame(width: 46, height: 46)
                                    .overlay {
                                        Image(systemName: transaction.type == "Income" ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                                            .font(.system(size: 26))
                                            .foregroundColor(transaction.type == "Income" ? .green : .red)
                                    }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(transaction.category.name)
                                        .font(.headline)
                                    
                                    if !transaction.note.isEmpty {
                                        Text(transaction.note)
                                            .foregroundColor(.gray)
                                            .font(.caption)
                                    }
                                    
                                    Text(transaction.date, style: .date)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                // MARK: - Amount
                                Text("₹\(transaction.amount, specifier: "%.2f")")
                                    .bold()
                                    .foregroundColor(transaction.type == "Income" ? .green : .red)
                            }
                            .swipeActions {
                                Button(role: .destructive) {
                                    viewModel.deleteTransaction(transaction: transaction, context: context)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Transactions")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showFilters.toggle()
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .onAppear {
                viewModel.loadData(context: context)
            }
            .sheet(isPresented: $showFilters) {
                FiltersView(viewModel: viewModel)
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
