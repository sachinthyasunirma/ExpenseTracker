//
//  AccountRepository.swift
//  ExpenseTracker
//
//  Created by sachinthya sunirma rathnavibushana on 2025-04-23.
//

import Foundation
import CoreData

class AccountRepository: ObservableObject {
    private let context = CoreDataService.shared.context;
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func fetchAccounts() async throws -> [Account] {
        try await context.perform{
            let request: NSFetchRequest<Account> = Account.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
            return try self.context.fetch(request)
        }
    }
    
    func saveAccount(name: String, type: String, currency: String, initialBalance: Decimal) async throws -> Account {
        let account = Account(context: context)
        account.id = UUID()
        account.name = name
        account.type = type
        account.currency = currency
        account.initialBalance = (initialBalance) as NSDecimalNumber
        account.currentBalance = (initialBalance) as NSDecimalNumber
        account.isActive = true
        account.createdAt = Date()
        account.updatedAt = Date()
        try await context.perform {
            try self.context.save()
        }
        return account;
    }
    
    func fetchActiveAccounts() async throws -> [Account] {
        try await context.perform{
            let request: NSFetchRequest<Account> = Account.fetchRequest()
            request.predicate = NSPredicate(format: "isActive == true")
            request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
            return try self.context.fetch(request)
        }
    }
    
    func fetchAccount(id: UUID) async throws -> Account? {
        try await context.perform{
            let request: NSFetchRequest<Account> = Account.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id.uuidString)
            request.fetchLimit = 1
            return try self.context.fetch(request)[0]
        }
    }
    
    func updateAccount(account: Account) async throws {
        account.updatedAt = Date()
        try await context.perform {
            try self.context.save()
        }
    }
    
    func deleteAccount(account: Account) async throws {
        context.delete(account)
        try await context.perform {
            try self.context.save()
        }
    }
    
    func updateAccountStatus(id: UUID, isActive: Bool) async throws {
        guard var account = try await fetchAccount(id: id) else {
            throw AccountError.accountNotFound
        }
        account.isActive = isActive
        try await updateAccount(account: account)
    }
    
    func fetchCurrentBalance(for id: UUID) async throws -> Decimal {
        guard let account = try await fetchAccount(id: id) else {
            throw AccountError.accountNotFound
        }
        return account.currentBalance! as Decimal
    }
}

enum AccountError : Error {
    case accountNotFound
    case insufficientFunds
    case invalidAccount
}
