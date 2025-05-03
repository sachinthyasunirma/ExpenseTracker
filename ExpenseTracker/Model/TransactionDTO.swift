//
//  TransactionDTO.swift
//  ExpenseTracker
//
//  Created by sachinthya sunirma rathnavibushana on 2025-05-03.
//

import Foundation

struct TransactionDTO {
    let id: UUID
    let amount: Decimal
    let date: Date
    let description: String
    let isIncome: Bool
    let merchantName: String
    let status: String
    let receiptImagePath: String?
    let location: String?
    let currencyCode: String
    let exchangeRate: Decimal
    
    // Foreign keys
    let accountId: UUID
    let categoryId: UUID
}
