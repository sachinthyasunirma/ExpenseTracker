//
//  Account+Extension.swift
//  ExpenseTracker
//
//  Created by sachinthya sunirma rathnavibushana on 2025-04-23.
//

import Foundation
import CoreData

extension Account {
    static func previewAccount(context: NSManagedObjectContext) -> Account {
        let account = Account(context: context)
        account.name = "Savings"
        account.currentBalance = 2450.75
        account.currency = "USD"
        account.isActive = true
        return account
    }
}
