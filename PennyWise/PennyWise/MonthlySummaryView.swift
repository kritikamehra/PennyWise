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
    // MARK: - Properties
    @State private var selectedRange: SummaryTimeRange = .month
    @State private var selectedChart: SummaryChartType = .pie
    @State private var selectedMonth: Date = Date()
    @State private var showMonthPicker = false
    @Query(sort: \Transaction.date, order: .reverse)
    private var allTransactions: [Transaction]
    @Environment(\.modelContext) private var context
    @State var viewModel = MonthlySummaryViewModel()
    
    private let months = Calendar.current.monthSymbols
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                
                // MARK: Month Picker
                Button {
                    showMonthPicker.toggle()
                } label: {
                    HStack {
                        Text(months[viewModel.selectedMonthIndex])
                            .font(.headline)
                            .foregroundColor(Color("TextPrimary"))
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundColor(Color("Secondary"))
                    }
                    .padding()
                    .background(Color("Surface"))
                    .cornerRadius(12)
                }
                .sheet(isPresented: $showMonthPicker) {
                    monthPickerSheet
                }
                
                // MARK: Overview
                SectionHeader("Overview", icon: "chart.bar")
                
                HStack(spacing: 12) {
                    SummaryCard(title: "Income", amount: viewModel.totalIncome, color: .green)
                    SummaryCard(title: "Expense", amount: viewModel.totalExpense, color: .red)
                    SummaryCard(title: "Savings", amount: viewModel.savings, color: .blue)
                }
                .padding(.horizontal)
                
                // MARK: Charts
                SectionHeader("Charts", icon: "chart.pie")
                
                chartTypePicker
                    .padding(.horizontal)
                
                chartSection
                    .padding(.horizontal)
                
                // MARK: Expense Categories
                SectionHeader("Expense Categories", icon: "folder")
                
                categorySection
                    .padding(.horizontal)
            }
            .padding(.top, 12)
            .padding(.horizontal , 12)
            .onAppear {
                viewModel.update(context: context)
            }
        }
        .background(Color("Background"))
        .navigationTitle("Summary – \(months[viewModel.selectedMonthIndex])")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: Month Sheet
    var monthPickerSheet: some View {
        NavigationStack {
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
                                .foregroundColor(Color("Primary"))
                        }
                    }
                }
            }
            .navigationTitle("Select Month")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showMonthPicker = false
                    }
                }
            }
        }
    }
}

// MARK: - Helpers
extension MonthlySummaryView {
    
    var filteredTransactions: [Transaction] {
        let cal = Calendar.current
        let now = Date()

        switch selectedRange {
        case .month:
            return allTransactions.filter { cal.isDate($0.date, equalTo: now, toGranularity: .month) }
        case .year:
            let start = cal.date(byAdding: .year, value: -1, to: now)!
            return allTransactions.filter { $0.date >= start }
        }
    }
    
    func filteredIncome() -> Double {
        filteredTransactions.filter { $0.type == "Income" }
            .reduce(0) { $0 + $1.amount }
    }
    
    func filteredExpense() -> Double {
        filteredTransactions.filter { $0.type == "Expense" }
            .reduce(0) { $0 + $1.amount }
    }
    
    // Month-scoped EXPENSES ONLY category breakdown using the view model’s monthlyTransactions
    func monthlyExpenseCategoryBreakdown() -> [(category: String, amount: Double)] {
        let expenses = viewModel.monthlyTransactions.filter { $0.type == "Expense" }
        let grouped = Dictionary(grouping: expenses) { $0.category.name }
        let mapped = grouped.map { (category: $0.key,
                                    amount: $0.value.reduce(0) { $0 + $1.amount }) }
        return mapped.sorted { $0.amount > $1.amount }
    }
    
    // Month-scoped EXPENSES ONLY daily trend within selected month
    func monthlyExpenseTrendByDay() -> [(period: String, amount: Double)] {
        let calendar = Calendar.current
        let expenses = viewModel.monthlyTransactions.filter { $0.type == "Expense" }
        
        // Group by day number in the selected month
        let grouped = Dictionary(grouping: expenses) { tx -> Int in
            calendar.component(.day, from: tx.date)
        }
        
        // Map to (dayLabel, total) and sort by day ascending
        let mapped = grouped.map { (day: $0.key,
                                    amount: $0.value.reduce(0) { $0 + $1.amount }) }
            .sorted { $0.day < $1.day }
            .map { (period: String($0.day), amount: $0.amount) }
        
        return mapped
    }
}


// MARK: - Category Section
extension MonthlySummaryView {
    
    @ViewBuilder
    var categorySection: some View {
        let data = monthlyExpenseCategoryBreakdown()
        
        VStack(spacing: 10) {
            ForEach(data, id: \.category) { item in
                HStack {
                    Text(item.category)
                        .foregroundColor(Color("TextPrimary"))
                    Spacer()
                    Text("₹\(item.amount, specifier: "%.2f")")
                        .fontWeight(.semibold)
                        .foregroundColor(Color("Primary"))
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(Color("Surface"))
                .cornerRadius(8)
            }
            
            if data.isEmpty {
                Text("No expense data for this month.")
                    .foregroundColor(.secondary)
                    .padding(.vertical, 8)
            }
        }
    }
    
    // Kept for other call sites if any still reference it
    func categoryBreakdown() -> [(category: String, amount: Double)]? {
        let grouped = Dictionary(
            grouping: filteredTransactions.filter { $0.type == "Expense" }
        ) { $0.category.name }

        let mapped = grouped.map { (category: $0.key,
                                    amount: $0.value.reduce(0) { $0 + $1.amount }) }

        return mapped.sorted { $0.amount > $1.amount }
    }
}

// MARK: - Chart Type Picker
extension MonthlySummaryView {
    var chartTypePicker: some View {
        Picker("Chart Type", selection: $selectedChart) {
            ForEach(SummaryChartType.allCases) { type in
                Text(type.rawValue)
                    .tag(type)
            }
        }
        .pickerStyle(.segmented)
    }
}


// MARK: - Chart Section
extension MonthlySummaryView {
    @ViewBuilder
    var chartSection: some View {
        switch selectedChart {
        case .pie:
            pieChartSection
        case .bar:
            barChartSection
        case .line:
            lineChartSection
        }
    }
}


// MARK: - Pie Chart
extension MonthlySummaryView {
    var pieChartSection: some View {
        return VStack {
            let data = monthlyExpenseCategoryBreakdown()
            if !data.isEmpty {
                Chart(data, id: \.category) { item in
                    SectorMark(
                        angle: .value("Amount", item.amount),
                        innerRadius: .ratio(0.45)
                    )
                    .foregroundStyle(by: .value("Category", item.category))
                }
                .frame(height: 280)
            } else {
                Text("No data available.")
                    .foregroundColor(.secondary)
            }
        }
    }
}


// MARK: - Bar Chart + Line Chart
extension MonthlySummaryView {
    
    var barChartSection: some View {
        return VStack {
            let data = monthlyExpenseCategoryBreakdown()
            if !data.isEmpty {
                Chart(data, id: \.category) { item in
                    // Bar
                    BarMark(
                        x: .value("Category", item.category),
                        y: .value("Amount", item.amount)
                    )
                    // Category name ABOVE the bar
                    .annotation(position: .top) {
                        Text(item.category)
                            .font(FontStyle.caption)
                            .foregroundColor(Color("Secondary"))
                        //                    .rotationEffect(.degrees(-30)) // optional, if long names
                            .frame(maxWidth: 60)           // optional clipping
                    }
                }
                .chartXAxis(.hidden)   // hide bottom labels completely
                .frame(height: 280)
            } else {
                Text("No data available.")
                    .foregroundColor(.secondary)
            }
        }
        .chartXAxis(.hidden)   // 🔥 hide bottom labels completely
        .frame(height: 280)
    }

    
    var lineChartSection: some View {
        let data = monthlyExpenseTrendByDay()
        return VStack {
            if !data.isEmpty {
                Chart(data, id: \.period) { item in
                    LineMark(
                        x: .value("Day", item.period),
                        y: .value("Total Expense", item.amount)
                    )
                    .symbol(Circle())
                }
                .frame(height: 280)
            } else {
                Text("No data available.")
                    .foregroundColor(.secondary)
            }
        }
        .frame(height: 280)
    }
    
    func timeRangeBreakdown() -> [(label: String, amount: Double)]? {
        monthlyBreakdown()
    }
    
    func monthlyBreakdown() -> [(String, Double)] {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        
        let grouped = Dictionary(
            grouping: filteredTransactions
        ) { formatter.string(from: $0.date) }
        
        return grouped.map { (label: $0.key,
                              amount: $0.value.reduce(0) { $0 + $1.amount }) }
        .sorted { $0.label < $1.label }
    }
    
    func trendData() -> [(period: String, amount: Double)] {
        monthlyBreakdown().map { ($0.0, $0.1) }
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
        .frame(height: 90)
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

enum SummaryChartType: String, CaseIterable, Identifiable {
    case pie = "Category Pie"
    case bar = "Bars"
    case line = "Trends"

    var id: String { rawValue }
}

enum SummaryTimeRange: String, CaseIterable, Identifiable {
    case month = "Monthly"
    case year = "Yearly"

    var id: String { rawValue }
}

// MARK: Preview
#Preview {
    MonthlySummaryView()
}
