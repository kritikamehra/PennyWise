//
//  CategoryModel.swift
//  PennyWise
//
//  Created by Kritika Mehra on 05/10/25.
//

import SwiftData

@Model
class Category {
    var name: String
    
    init(name: String) {
        self.name = name
    }
}
