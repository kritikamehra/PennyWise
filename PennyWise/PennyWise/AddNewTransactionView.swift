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
    @State private var amount: String = ""
    @State private var type: String = ""
    @State private var date: Date = Date()
    @State private var note: String = ""
    @State private var selectedCategory: Category?
    @State private var showAddCategory = false
    @State private var newCategoryName: String = ""
    @Query(sort: \Category.name) private var categories: [Category] //fetch existing categories
    var body: some View {
        Form {
            TextField("Amount", text: $amount)
                .keyboardType(.decimalPad)
            Picker("Type", selection: $type) {
                Text("Income").tag("Income")
                Text("Expense").tag("Expense")
            }
            
            DatePicker("Date", selection: $date, displayedComponents: .date)
            
            TextField("Note", text: $note)
            
            Picker("Category", selection: $selectedCategory) {
                ForEach(categories) { category in
                    Text(category.name).tag(category as Category?)
                }
                Text("Add").tag((Category(name: "Add")) as Category?)
            }
            
            .onChange(of: selectedCategory, { _, newValue in
                if newValue?.name == "Add" {
                    showAddCategory = true
                }
            })
            .alert("Add New Category", isPresented: $showAddCategory) {
                TextField("Category name", text: $newCategoryName)
                Button("Cancel", role: .cancel) { newCategoryName = "" }
                Button("Add") {
                    guard !newCategoryName.isEmpty else { return }
                    let newCategory = Category(name: newCategoryName)
                    context.insert(newCategory)
                    try? context.save()
                    selectedCategory = newCategory
                    newCategoryName = ""
                }
            }
            
            Button("Save Transaction") {
                if let amt = Double(amount) {
                    let newTransaction = Transaction(amount: amt, type: type, date: date, note: note, category: selectedCategory)
                    context.insert(newTransaction)
                    try? context.save()
                    
                    
                    //reset form
                    amount = ""
                    note = ""
                    type = ""
                    selectedCategory = nil
                    date = Date()
                }
            }
        }
    }
}

#Preview {
    AddNewTransactionView()
}
