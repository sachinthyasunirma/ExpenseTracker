//
//  Account.swift
//  ExpenseTracker
//
//  Created by sachinthya sunirma rathnavibushana on 2025-04-21.
//

import Foundation

struct AccountResponse: Identifiable, Codable {
    var id: UUID
    var name: String
    var type: AccountType
    var currency: Currency
    var initialBalance: Decimal
    var currentBalance: Decimal
    var isActive: Bool
    var createdAt: Date
    var updatedAt: Date
    
    init(id: UUID = UUID(), name: String, type: AccountType, currency: Currency, initialBalance: Decimal) {
        self.id = id
        self.name = name
        self.type = type
        self.currency = currency
        self.initialBalance = initialBalance
        self.currentBalance = initialBalance
        self.isActive = true
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

enum AccountType: String, Identifiable, CaseIterable, Codable {
    case cash = "Cash"
    case checking = "Checking"
    case savings = "Savings"
    case creditCard = "Credit Card"
    case investment = "Investment"
    case loan = "Loan"
    case other = "Other"
    
    var id: String { self.rawValue }
}

enum Currency: String, Codable, CaseIterable, Identifiable {
    case usd = "USD"
    case eur = "EUR"
    case gbp = "GBP"
    case jpy = "JPY"
    case cad = "CAD"
    case aud = "AUD"
    case inr = "INR"
    case cny = "CNY"
    case other = "Other"
    
    var id: String { self.rawValue }
    
    var symbol: String {
        switch self {
        case .usd: return "$"
        case .eur: return "€"
        case .gbp: return "£"
        case .jpy: return "¥"
        case .cad: return "C$"
        case .aud: return "A$"
        case .inr: return "₹"
        case .cny: return "¥"
        case .other: return "#"
        }
    }
}
