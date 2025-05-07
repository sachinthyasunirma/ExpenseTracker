//
//  CategoryDTO.swift
//  ExpenseTracker
//
//  Created by sachinthya sunirma rathnavibushana on 2025-05-05.
//

import Foundation

struct CategoryDTO: Identifiable, Codable {
    let categoryID: UUID
    var name: String?
    var color: String?
    var icon: String?
    
    var id: UUID { categoryID }

    init(categoryID: UUID) {
        self.categoryID = categoryID
    }

    init(categoryID: UUID, name: String, color: String, icon: String) {
        self.categoryID = categoryID
        self.name = name
        self.color = color
        self.icon = icon
    }
}

