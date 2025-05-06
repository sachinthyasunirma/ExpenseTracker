//
//  Budget.swift
//  ExpenseTracker
//
//  Created by user271709 on 5/6/25.
//

// 1. Budget.swift (Model)
import Foundation

struct BudgetDTO: Identifiable, Codable {
    let id: UUID
    var name: String
    var categoryID: UUID
    var amountLimit: Double
    var startDate: Date
    var endDate: Date
    var notifyAtPercent: Double
}
