//
//  MonthlySummaryView.swift
//  PennyWise
//
//  Created by Kritika Mehra on 05/11/25.
//

import SwiftUI
import SwiftData
import Charts

struct MonthlySummaryView: View {
    @Environment(\.modelContext) private var context
    @State var viewModel = MonthlySummaryViewModel()
    @State private var showMonthPicker = false
    
    private let months = Calendar.current.monthSymbols
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                
                // MARK: - MONTH SELECTOR
                Button {
                    showMonthPicker.toggle()
                } label: {
                    HStack {
                        Text(months[viewModel.selectedMonthIndex])
                            .font(.headline)
                        Spacer()
                        Image(systemName: "chevron.down")
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .sheet(isPresented: $showMonthPicker) {
                    monthPickerSheet
                }
                
                
                
                // MARK: - SUMMARY CARDS
                VStack(alignment: .leading, spacing: 12) {
                    Text("Overview")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    HStack(spacing: 16) {
                        SummaryCard(title: "Income",
                                    amount: viewModel.totalIncome,
                                    color: .green)
                        
                        SummaryCard(title: "Expense",
                                    amount: viewModel.totalExpense,
                                    color: .red)
                        
                        SummaryCard(title: "Savings",
                                    amount: viewModel.savings,
                                    color: .blue)
                    }
                    .padding(.horizontal)
                }
                
                
                // MARK: - LAST 6 MONTHS CHART
                VStack(alignment: .leading, spacing: 10) {
                    Text("Last 6 Months")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    Chart(viewModel.lastSixMonthsData, id: \.month) { item in
                        BarMark(
                            x: .value("Month", item.month),
                            y: .value("Total", item.total)
                        )
                    }
                    .frame(height: 250)
                    .padding(.horizontal)
                }
                
                
                // MARK: - EXPENSE CATEGORIES
                VStack(alignment: .leading, spacing: 12) {
                    Text("Expense Categories")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    VStack(spacing: 10) {
                        ForEach(viewModel.expenseCategoryTotals, id: \.category) { item in
                            HStack {
                                Text(item.category)
                                Spacer()
                                Text("₹\(item.amount, specifier: "%.2f")")
                                    .bold()
                            }
                            .padding(.vertical, 6)
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .padding(.top, 10)
            .onAppear {
                viewModel.update(context: context)
            }
        }
        .navigationTitle("Monthly Summary – \(months[viewModel.selectedMonthIndex])")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    var monthPickerSheet: some View {
        VStack {
            Text("Select Month")
                .font(.title2.bold())
                .padding()
            
            List(0..<12, id: \.self) { i in
                Button {
                    viewModel.selectedMonthIndex = i
                    showMonthPicker = false
                    viewModel.update(context: context)
                } label: {
                    HStack {
                        Text(months[i])
                        Spacer()
                        if viewModel.selectedMonthIndex == i {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
        }
    }
}



// MARK: - Summary Card Component
struct SummaryCard: View {
    let title: String
    let amount: Double
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            
            Text("₹\(amount, specifier: "%.0f")")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(color)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
        .padding()
        // FIX: Removed fixed width to allow the card to flex and fit three across
        // .frame(width: 130, height: 90)
        .frame(height: 90) // Keep the height
        .frame(maxWidth: .infinity) // Allow the card to take up equal space
        .background(Color(.systemGray6))
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}


#Preview {
    MonthlySummaryView()
}
