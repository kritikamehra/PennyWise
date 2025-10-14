//
//  ManageCategoriesView.swift
//  PennyWise
//
//  Created by Kritika Mehra on 07/10/25.
//

import SwiftUI
import SwiftData

struct ManageCategoriesView: View {
    @Environment(\.modelContext) private var context
    @State private var viewModel = ManageCategoriesViewModel()
    @Query(sort: \Category.name) private var categories: [Category]
    @State private var showAddCategoryAlert = false
    @State private var alreadyExistsAlert = false
    @State private var newCategoryName: String = ""
    var body: some View {
        Form {
            Section("Categories") {
                List {
                    ForEach(viewModel.categories) { category in
                        Text(category.name)
                    }
                    .onDelete(perform: deleteCategory)
                }
            }
            
            Section {
                Button("Add New Category") {
                    showAddCategoryAlert = true
                }
                .alert("Add New Category", isPresented: $showAddCategoryAlert) {
                    TextField("Category name", text: $viewModel.newCategoryName)
                    Button("Cancel", role: .cancel) { viewModel.newCategoryName = "" }
                    Button("Add") {
                        if !viewModel.addCategory(context: context) {
                            alreadyExistsAlert = true
                        }
                    }
                }
                
                .alert("Category already exists", isPresented: $alreadyExistsAlert) {
                    Button("Cancel", role: .cancel) { viewModel.newCategoryName = "" }
                }
            }
        }
        .navigationTitle("Manage Category")
        .onAppear {
            viewModel.fetchCategories(from: context)
        }
    }
    
    func deleteCategory(at indexsets: IndexSet) {
        for index in indexsets {
            let category = categories[index]
            viewModel.deleteCategory(category: category, context: context)
        }
    }
}

#Preview {
    ManageCategoriesView()
}
