//
//  HomeView.swift
//  PennyWise
//
//  Created by Kritika Mehra on 05/10/25.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    
    @Environment(\.modelContext) private var context
    @State var viewModel = HomeViewModel()

    @State private var showFilters = false
    @State private var selectedTransaction: Transaction?
    @State private var showEditSheet: Bool = false

    var body: some View {
        NavigationStack {
            VStack(spacing: Spacing.medium) {

                // MARK: - Quick Filter
                Picker("Filter", selection: $viewModel.selectedType) {
                    ForEach(TransactionTypeFilter.allCases) { type in
                        Text(type.rawValue)
                            .font(FontStyle.body)
                            .tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                // MARK: - Empty State
                if viewModel.filteredTransactions.isEmpty {
                    ContentUnavailableView(
                        "No Transactions",
                        systemImage: "tray",
                        description: Text("Try changing your filters.")
                    )
                    .padding(.top, Spacing.large)

                } else {

                    // MARK: - List
                    List {
                        ForEach(viewModel.filteredTransactions) { transaction in
                            TransactionRow(transaction: transaction)
//                                .swipeActions {
//                                    Button(role: .destructive) {
//                                        viewModel.deleteTransaction(transaction: transaction,
//                                                                    context: context)
//                                    } label: {
//                                        Label("Delete", systemImage: "trash")
//                                    }
//                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {

                                    Button(role: .destructive) {
                                        viewModel.deleteTransaction(transaction: transaction, context: context)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }

                                    Button {
                                        selectedTransaction = transaction
                                        showEditSheet = true
                                    } label: {
                                        Label("Edit", systemImage: "pencil")
                                    }
                                    .tint(.blue)
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
                            .font(.headline)
                    }
                }
            }
            .onAppear {
                viewModel.loadData(context: context)
            }
            .sheet(isPresented: $showFilters) {
                FiltersView(viewModel: viewModel)
            }
            .sheet(item: $selectedTransaction, onDismiss: {
                       viewModel.fetchTransactions(context: context)
                   }) { tx in
                       EditTransactionView(transaction: tx)
                   }      }
        .background(ColorPalette.background.ignoresSafeArea())
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
