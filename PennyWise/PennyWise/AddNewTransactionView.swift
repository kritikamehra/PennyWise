//
//  HomeView.swift
//  PennyWise
//
//  Created by Kritika Mehra on 05/10/25.
//

import SwiftUI
import SwiftData

struct AddNewTransactionView: View {
    
    @Environment(\.modelContext) var context
    @Query(sort: \Category.name) private var categories: [Category] //fetch existing categories
    @State private var viewModel = AddNewTransactionViewModel()
    
    @State private var amount: String = ""
    @State private var type: String = ""
    @State private var date: Date = Date()
    @State private var note: String = ""
    @State private var selectedCategory: Category?
    @State private var newCategoryName: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Details"){
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                    Picker("Type", selection: $type) {
                        Text("Income").tag("Income")
                        Text("Expense").tag("Expense")
                    }
                    
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    
                    TextField("Note", text: $note)
                }
                
                Section("Category") {
                    Picker("Select Category", selection: $selectedCategory) {
                        ForEach(categories) { category in
                            Text(category.name).tag(category as Category?)
                        }
                    }
                    NavigationLink("Manage Categories") {
                        ManageCategoriesView()
                    }
                    .foregroundColor(.blue)
                }
                
                Button("Save Transaction") {
                    let success = viewModel.saveTransaction(amount: amount, type: type, date: date, note: note, category: selectedCategory, context: context)
                    
                    if success {
                        //reset form
                        amount = ""
                        note = ""
                        type = ""
                        selectedCategory = nil
                        date = Date()
                    }
                }
                .alert(viewModel.alertMessage, isPresented: $viewModel.showAlert) {
                    Button("Ok", role: .cancel) {}
                }
            }
            .navigationTitle("Add new Transaction")
        }
    }
}

#Preview {
    AddNewTransactionView()
}
