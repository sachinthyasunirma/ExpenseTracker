//
//  CategoryDTO.swift
//  ExpenseTracker
//
//  Created by sachinthya sunirma rathnavibushana on 2025-05-05.
//

import Foundation

struct CategoryDTO: Codable {
    var name: String?
    var color: String?
    var icon: String?

    init() {}

    init(name: String, color: String, icon: String) {
        self.name = name
        self.color = color
        self.icon = icon
    }
}

