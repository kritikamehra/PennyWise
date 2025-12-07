//
//  EditTransactionView.swift
//  PennyWise
//
//  Created by Kritika Mehra on 17/11/25.
//

import SwiftUI
import SwiftData

struct EditTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var transaction: Transaction
    @Query(sort: \Category.name) private var allCategories: [Category]

    @State var viewModel = EditTransactionViewModel()

    var body: some View {
        NavigationStack {
            Form {

                // MARK: - Amount
                Section(header: SectionHeader("Amount", icon: "dollarsign")) {
                    TextField("Amount", text: $viewModel.amountText)
                        .keyboardType(.decimalPad)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(Color("TextPrimary"))
                }

                // MARK: - Type
                Section(header: SectionHeader("Type", icon: "arrow.up.arrow.down")) {
                    Picker("", selection: $viewModel.type) {
                        Text("Income")
                            .tag("Income")
                        Text("Expense")
                            .tag("Expense")
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: viewModel.type) { _ in
                        viewModel.updateCategoryForType(allCategories: allCategories)
                    }
                }

                // MARK: - Category
                Section(header: SectionHeader("Category", icon: "tag")) {
                    let filtered = viewModel.filteredCategories(from: allCategories)

                    if filtered.isEmpty {
                        Text("No categories available")
                            .foregroundColor(Color("TextSecondary"))
                            .font(.caption)
                    } else {
                        Picker("Select Category", selection: $viewModel.selectedCategory) {
                            ForEach(filtered) { category in
                                Text(category.name)
                                    .tag(Optional(category))
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }

                // MARK: - Date
                Section(header: SectionHeader("Date", icon: "calendar")) {
                    DatePicker("Select Date", selection: $viewModel.date, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .font(.system(size: 16))
                }

                // MARK: - Note
                Section(header: SectionHeader("Note", icon: "square.and.pencil")) {
                    TextField("Add a note", text: $viewModel.note)
                        .font(.system(size: 16))
                        .foregroundColor(Color("TextPrimary"))
                }
            }
            .padding(.top, Spacing.large)
            .scrollContentBackground(.hidden)
            .background(Color("Background"))
            .navigationTitle("Edit Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(Color("Secondary"))
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.apply(to: transaction)
                        dismiss()
                    }
                    .disabled(!viewModel.isFormValid)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(viewModel.isFormValid ? Color("Primary") : Color("TextSecondary"))
                }
            }
            .onAppear {
                viewModel.load(from: transaction, allCategories: allCategories)
            }
        }
    }
}
