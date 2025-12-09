//
//  EditCategorySheet.swift
//  PennyWise
//
//  Created by Kritika Mehra on 09/12/25.
//

import SwiftUI

struct EditCategorySheet: View {
    @State var name: String
    @State var type: CategoryType
    @Environment(\.dismiss) var dismiss
    @FocusState private var isFocused: Bool
    let onSave: (String, CategoryType) -> Void
    
    init(category: Category?, onSave: @escaping (String, CategoryType) -> Void) {
        _name = State(initialValue: category?.name ?? "")
        _type = State(initialValue: category?.type ?? .expense)
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $name)
                    .focused($isFocused)
                Picker("Type", selection: $type) {
                    ForEach(CategoryType.allCases) { t in
                        Text(t.rawValue).tag(t)
                    }
                }
            }
            .highPriorityGesture(TapGesture().onEnded {
                isFocused = false
            })
            .navigationTitle("Edit Category")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        isFocused = false
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        isFocused = false // dismiss keyboard
                        onSave(name, type)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

