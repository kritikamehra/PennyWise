//
//  CategoryModel.swift
//  PennyWise
//
//  Created by Kritika Mehra on 05/10/25.
//

import SwiftData
import Foundation

enum CategoryType: String, Codable, CaseIterable, Identifiable {
    case income = "Income"
    case expense = "Expense"
    var id: String { self.rawValue }
}

@Model
class Category {
    var name: String
    var type: CategoryType
    var createdAt: Date

    init(name: String, type: CategoryType = CategoryType.expense) {
        self.name = name
        self.type = type
        self.createdAt = Date()
    }
}
