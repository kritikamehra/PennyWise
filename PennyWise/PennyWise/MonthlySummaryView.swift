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
    @State private var selectedRange: SummaryTimeRange = .month //default selected
    @Query(sort: \Transaction.date, order: .reverse)
    private var allTransactions: [Transaction]
    @State private var selectedChart: SummaryChartType = .pie // default chart
       @State private var selectedTimeRange: SummaryTimeRange = .month
    @State private var selectedMonth: Date = Date()
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
//                VStack(alignment: .leading, spacing: 12) {
//                    Text("Overview")
//                        .font(.headline)
//                        .padding(.horizontal)
//                    
//                    HStack(spacing: 16) {
//                        SummaryCard(title: "Income",
//                                    amount: viewModel.totalIncome,
//                                    color: .green)
//                        
//                        SummaryCard(title: "Expense",
//                                    amount: viewModel.totalExpense,
//                                    color: .red)
//                        
//                        SummaryCard(title: "Savings",
//                                    amount: viewModel.savings,
//                                    color: .blue)
//                    }
//                    .padding(.horizontal)
//                }
               
                    let income = filteredTransactions.filter { $0.type == "Income" }.reduce(0) { $0 + $1.amount }
                    let expense = filteredTransactions.filter { $0.type == "Expense" }.reduce(0) { $0 + $1.amount }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Overview")
                            .font(.headline)
                            .padding(.horizontal)

                        HStack(spacing: 16) {
                            SummaryCard(title: "Income", amount: income, color: .green)
                            SummaryCard(title: "Expense", amount: expense, color: .red)
                            SummaryCard(title: "Savings", amount: income - expense, color: .blue)
                        }
                        .padding(.horizontal)
                    }
                

                
                // MARK: - LAST 6 MONTHS CHART
//                VStack(alignment: .leading, spacing: 10) {
////                    Text("Last 6 Months")
////                        .font(.headline)
////                        .padding(.horizontal)
//
//                    chartTypePicker
//                    timelineSelector
//                    chartSection
//                    
////                    Chart(viewModel.lastSixMonthsData, id: \.month) { item in
////                        BarMark(
////                            x: .value("Month", item.month),
////                            y: .value("Total", item.total)
////                        )
////                    }
////                    .frame(height: 250)
////                    .padding(.horizontal)
//                }
//                VStack(alignment: .leading, spacing: 18) {
//
//                    monthPickerSection
//
//                    summarySection
//
//                    chartTypePicker
//
//                    chartSection
//                }
//                .padding()

                
                
                // MARK: - EXPENSE CATEGORIES
                
//                VStack(alignment: .leading, spacing: 12) {
//                    Text("Expense Categories")
//                        .font(.headline)
//                        .padding(.horizontal)
//                    
//                    VStack(spacing: 10) {
//                        ForEach(viewModel.expenseCategoryTotals, id: \.category) { item in
//                            HStack {
//                                Text(item.category)
//                                Spacer()
//                                Text("₹\(item.amount, specifier: "%.2f")")
//                                    .bold()
//                            }
//                            .padding(.vertical, 6)
//                            .padding(.horizontal)
//                        }
//                    }
//                }
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Expense Categories")
                            .font(.headline)
                            .padding(.horizontal)

                        let data = categoryBreakdown() ?? []

                        VStack(spacing: 10) {
                            ForEach(data, id: \.category) { item in
                                HStack {
                                    Text(item.category)
                                    Spacer()
                                    Text("₹\(item.amount, specifier: "%.2f")")
                                        .bold()
                                }
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


// MARK: - MONTH PICKER
extension MonthlySummaryView {
    var monthPickerSection: some View {
        DatePicker(
            "Select Month",
            selection: $selectedMonth,
            displayedComponents: [.date]
        )
        .datePickerStyle(.graphical)
        .padding(.bottom, 8)
    }
}


// MARK: - SUMMARY (Income / Expense / Balance)
extension MonthlySummaryView {

    var summarySection: some View {
        let (income, expense) = calculateMonthlyTotals()

        return VStack(alignment: .leading, spacing: 10) {
            Text("Overview")
                .font(.title3)
                .bold()

            HStack {
                VStack(alignment: .leading) {
                    Text("Income")
                        .font(.subheadline)
                        .foregroundColor(.green)
                    Text("₹\(Int(income))")
                        .font(.headline)
                        .bold()
                }
                Spacer()
                VStack(alignment: .leading) {
                    Text("Expense")
                        .font(.subheadline)
                        .foregroundColor(.red)
                    Text("₹\(Int(expense))")
                        .font(.headline)
                        .bold()
                }
                Spacer()
                VStack(alignment: .leading) {
                    Text("Balance")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    Text("₹\(Int(income - expense))")
                        .font(.headline)
                        .bold()
                }
            }
            .padding(.horizontal)
        }
    }

    // Helper
    func calculateMonthlyTotals() -> (Double, Double) {
        let filtered = allTransactions.filter { transaction in
            Calendar.current.isDate(transaction.date, equalTo: selectedMonth, toGranularity: .month)
        }

        let income = filtered.filter { $0.type == CategoryType.income.rawValue }.reduce(0) { $0 + $1.amount }
        let expense = filtered.filter { $0.type == CategoryType.expense.rawValue }.reduce(0) { $0 + $1.amount }

        return (income, expense)
    }
}


// MARK: - CHART TYPE PICKER
extension MonthlySummaryView {
    var chartTypePicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Chart Type")
                .font(.headline)

            Picker("Chart Type", selection: $selectedChart) {
                ForEach(SummaryChartType.allCases) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(.segmented)
        }
        .padding(.top, 12)
    }
}

// MARK: - CHART TIMELINE
extension MonthlySummaryView {
    var timelineSelector: some View {
        VStack(alignment: .leading) {
            Text("Timeline")
                .font(.headline)

            Picker("Time Range", selection: $selectedTimeRange) {
                ForEach(SummaryTimeRange.allCases) { range in
                    Text(range.rawValue).tag(range)
                }
            }
            .pickerStyle(.segmented)
        }
        .padding(.horizontal)
    }
    
    var filteredTransactions: [Transaction] {
        let cal = Calendar.current
        let now = Date()

        switch selectedTimeRange {
            
        case .month:
            return allTransactions.filter {
                cal.isDate($0.date, equalTo: now, toGranularity: .month)
            }

        case .year:
            let start = cal.date(byAdding: .year, value: -1, to: now)!
            return allTransactions.filter { $0.date >= start }
        }
    }

}

// MARK: - CHART SWITCHER
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


// MARK: - PIE CHART SECTION
extension MonthlySummaryView {
    var pieChartSection: some View {
        VStack(alignment: .leading) {
            Text("Expense Breakdown")
                .font(.headline)

            if let data = categoryBreakdown(), !data.isEmpty {
                Chart(data, id: \.category) { item in
                    SectorMark(
                        angle: .value("Amount", item.amount),
                        innerRadius: .ratio(0.45)
                    )
                    .foregroundStyle(by: .value("Category", item.category))
                }
                .frame(height: 280)

            } else {
                Text("No data for this month.")
                    .foregroundColor(.secondary)
            }
        }
    }

    func categoryBreakdown() -> [(category: String, amount: Double)]? {
        let grouped = Dictionary(
            grouping: filteredTransactions.filter { $0.type == "Expense" }
        ) { $0.category.name }

        let mapped = grouped.map { (category: $0.key,
                                    amount: $0.value.reduce(0) { $0 + $1.amount }) }

        return mapped.sorted { $0.amount > $1.amount }
    }
}


// MARK: - BAR CHART SECTION
extension MonthlySummaryView {
    var barChartSection: some View {
        VStack(alignment: .leading) {
            Text(selectedRangeTitle)
                .font(.headline)

            if let data = timeRangeBreakdown(), !data.isEmpty {
                Chart(data, id: \.label) { item in
                    BarMark(
                        x: .value("Label", item.label),
                        y: .value("Amount", item.amount)
                    )
                }
                .frame(height: 280)
            } else {
                Text("No data found.")
                    .foregroundColor(.secondary)
            }
        }
    }


    // MARK: - Picker Title
    var selectedRangeTitle: String {
        switch selectedRange {
        case .month: return "Monthly Breakdown"
        case .year: return "Yearly Breakdown"
        }
    }


    // MARK: - Data Processor
    func timeRangeBreakdown() -> [(label: String, amount: Double)]? {
        switch selectedRange {
        case .month:
            return monthlyBreakdown()
        case .year:
            return yearlyBreakdown()
        }
    }


    // MARK: - Helpers
    var calendar: Calendar { Calendar.current }

    private func monthlyBreakdown() -> [(label: String, amount: Double)] {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"

        let grouped = Dictionary(grouping: filteredTransactions) { tx in
            formatter.string(from: tx.date)
        }

        return grouped.map { (label: $0.key,
                              amount: $0.value.reduce(0) { $0 + $1.amount }) }
                      .sorted { $0.label < $1.label }
    }

    private func sixMonthBreakdown() -> [(label: String, amount: Double)] {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"

        let start = calendar.date(byAdding: .month, value: -5, to: Date())!
        let items = filteredTransactions.filter { $0.date >= start }

        let grouped = Dictionary(grouping: items) { tx in
            formatter.string(from: tx.date)
        }

        return grouped.map { (label: $0.key,
                              amount: $0.value.reduce(0) { $0 + $1.amount }) }
                      .sorted { $0.label < $1.label }
    }

    private func yearlyBreakdown() -> [(label: String, amount: Double)] {
        let grouped = Dictionary(grouping: filteredTransactions) { tx in
            let year = calendar.component(.year, from: tx.date)
            return "\(year)"
        }

        return grouped.map { (label: $0.key,
                              amount: $0.value.reduce(0) { $0 + $1.amount }) }
                      .sorted { $0.label < $1.label }
    }
}



// MARK: - LINE CHART SECTION
extension MonthlySummaryView {
    var lineChartSection: some View {
        VStack(alignment: .leading) {
            
            Text(selectedRange == .month ? "Daily Trend" : "Yearly Trend")
                .font(.headline)

            let data = trendData()

            if !data.isEmpty {
                Chart(data, id: \.period) { item in
                    LineMark(
                        x: .value(
                            selectedRange == .month ? "Day" : "Month",
                            item.period
                        ),
                        y: .value("Total", item.amount)
                    )
                    .foregroundStyle(item.type == CategoryType.expense.rawValue ? .red : .green)
                    .symbol(Circle())
                }
                .frame(height: 280)

            } else {
                Text("No data available.")
                    .foregroundColor(.secondary)
            }
        }
    }
    
    func trendData() -> [(period: String, amount: Double, type: String)] {
        switch selectedRange {
        case .month:
            return dailyTrend()
        case .year:
            return yearlyTrend()
        }
    }
    
    func dailyTrend() -> [(period: String, amount: Double, type: String)] {
        let calendar = Calendar.current
        
        // find start and end of selected month
        guard let range = calendar.range(of: .day, in: .month, for: selectedMonth) else {
            return []
        }
        
        let result = range.compactMap { day -> (period: String, amount: Double, type: String) in
            var components = calendar.dateComponents([.year, .month], from: selectedMonth)
            components.day = day
            guard let date = calendar.date(from: components) else { return ("", 0, "") }
            
            // day label
            let label = String(day)
            
            let filtered = filteredTransactions.filter {
                calendar.isDate($0.date, equalTo: date, toGranularity: .day)
            }
            
            let total = filtered.reduce(0) { $0 + $1.amount }
            let inferredType = filtered.first?.type ?? CategoryType.expense.rawValue
            
            return (period: label, amount: total, type: inferredType)
        }
        
        return result
    }
    
        func yearlyTrend() -> [(period: String, amount: Double, type: String)] {
            let calendar = Calendar.current

            let months = (0..<12).compactMap { offset in
                calendar.date(byAdding: .month, value: -offset, to: selectedMonth)
            }

            let result = months.map { date in
                // This makes the label show month: "Jan", "Feb", ...
                let label = date.formatted(.dateTime.month(.abbreviated))

                let monthTransactions = filteredTransactions.filter {
                    calendar.isDate($0.date, equalTo: date, toGranularity: .month)
                }

                let total = monthTransactions.reduce(0) { $0 + $1.amount }
                let inferredType = monthTransactions.first?.type ?? CategoryType.expense.rawValue

                return (period: label, amount: total, type: inferredType)
            }

            // So timeline appears Jan … Dec
            return result.reversed()
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



// MARK: - PREVIEW
#Preview {
    MonthlySummaryView()
}
