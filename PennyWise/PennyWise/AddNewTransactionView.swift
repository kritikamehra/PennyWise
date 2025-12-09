//
//  AddNewTransactionView.swift
//  PennyWise
//
//  Created by Kritika Mehra on 05/10/25.
//

import SwiftUI
import SwiftData

struct AddNewTransactionView: View {
    
    @Environment(\.modelContext) var context
    @Query(sort: \Category.name) private var categories: [Category]
    @StateObject private var viewModel = AddNewTransactionViewModel()
    @FocusState private var focusedField: Field?
    
    enum Field: Hashable {
           case amount
           case note
       }
    
    private var filteredCategories: [Category] {
        viewModel.filteredCategories(categories)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    
                    // MARK: - Details Card
                    SectionHeader("Details", icon: "doc.text.fill")
                    detailsCard()
                    
                    // MARK: - Category Card
                    SectionHeader("Category", icon: "tag.fill")
                    categoryCard()
                        .padding(.bottom, 10)
                    
                    // MARK: - Save Button
                    Button {
                        viewModel.saveTransaction(context: context)
                        focusedField = nil     // dismiss when saving
                    } label: {
                        Text("Save Transaction")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(viewModel.isSaveEnabled ? Color("Primary") : Color("Secondary"))
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .font(.headline)
                    }
                    .disabled(!viewModel.isSaveEnabled)
                }
                .padding(.horizontal)
                .padding(.top)
            }
            .onTapGesture {
                focusedField = nil     //  Dismiss Keyboard
            }
            .background(Color("Background").ignoresSafeArea())
            .navigationTitle("Add Transaction")
            .onAppear { viewModel.updateSelection(categories: categories) }
                        .onChange(of: categories) { _ in viewModel.updateSelection(categories: categories) }
                        .onChange(of: viewModel.type) { _ in viewModel.updateSelection(categories: categories) }
                        
            .alert(viewModel.alertMessage, isPresented: $viewModel.showAlert) {
                Button("OK", role: .cancel) {
                    // If it was a success alert, fields are already reset in the VM.
                    // If it was a "no categories" alert, keep selection update behavior.
                    viewModel.updateSelection(categories: categories)
                }
            }
        }
    }
    
    func detailsCard() -> some View {
        Card {
            VStack(alignment: .leading, spacing: 12) {
                Text("Amount")
                    .font(.footnote)
                    .foregroundColor(Color("TextSecondary"))
                
                TextField("0.00", text: $viewModel.amount)
                    .keyboardType(.decimalPad)
                    .inputField()
                    .focused($focusedField, equals: .amount)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Type")
                    .font(.footnote)
                    .foregroundColor(Color("TextSecondary"))
                
                Picker("", selection: $viewModel.type) {
                    Text("Income").tag("Income")
                    Text("Expense").tag("Expense")
                }
                .pickerStyle(.segmented)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Date")
                    .font(.footnote)
                    .foregroundColor(Color("TextSecondary"))
                
                DatePicker("Select Date", selection: $viewModel.date, displayedComponents: .date)
                    .foregroundStyle(Color("TextSecondary"))
                    .pickerField(showChevron: false)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Note")
                    .font(.footnote)
                    .foregroundColor(Color("TextSecondary"))
                
                TextField("Optional note", text: $viewModel.note)
                    .inputField()
                    .focused($focusedField, equals: .note)  // Add
                    .submitLabel(.done)
                    .onSubmit {
                        focusedField = nil     // Dismiss
                    }
            }
        }
        .padding(.bottom, 10)
    }
    
    func categoryCard() -> some View {
        Card {
            if filteredCategories.isEmpty {
                Text("No \(viewModel.type.lowercased()) categories available")
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Select Category")
                        .font(.footnote)
                        .foregroundColor(Color("TextSecondary"))
                    
                    Picker("Select Category", selection: $viewModel.selectedCategory) {
                        ForEach(filteredCategories) { category in
                            Text(category.name).tag(Optional(category))
                        }
                    }
                    .pickerStyle(.navigationLink)
                    .pickerField(showChevron: true)
                }
            }
            
            NavigationLink {
                ManageCategoriesView()
                    .modelContext(context)
            } label: {
                HStack {
                    Image(systemName: "slider.horizontal.3")
                    Text("Manage Categories")
                }
                .foregroundColor(Color("Primary"))
            }
            .font(.subheadline)
            .foregroundColor(Color("Primary"))
        }
        .padding(.bottom, 10)
    }
}

// MARK: - Field Styles
extension View {
    
    func inputField() -> some View {
        self
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color("Surface"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.25))
                    )
            )
    }
    
    func pickerField(showChevron: Bool = true) -> some View {
        HStack {
            self
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if showChevron {
                Image(systemName: "chevron.down")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray.opacity(0.6))
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.08))
        )
    }
}

#Preview {
    AddNewTransactionView()
}

