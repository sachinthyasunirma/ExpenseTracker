//
//  MockAccountService.swift
//  ExpenseTrackerTests
//
//  Created by sachinthya sunirma rathnavibushana on 2025-05-07.
//

@testable import ExpenseTracker
import Foundation

final class MockAccountService: AccountService {
    
    var shouldFail = false
    var testAccounts: [Account] = []
    
    func getAllAccounts() async throws -> [Account] {
        if shouldFail {
            throw NSError(domain: "MockError", code: 1, userInfo: nil)
        }
        return testAccounts
    }
    
    
    func createNewAccount(name: String, type: String, currency: String, initialBalance: Decimal) async throws -> Account {
        if shouldFail { throw AccountError.creationFailed }
        
        let account = Account(context: CoreDataService.shared.context)
        account.id = UUID()
        account.name = name
        account.type = type
        account.currency = currency
        account.initialBalance = NSDecimalNumber(decimal: initialBalance)
        account.currentBalance = NSDecimalNumber(decimal: initialBalance)
        account.createdAt = Date()
        account.updatedAt = Date()
        account.isActive = true
        testAccounts.append(account)
        return account
    }
    
    func getActiveAccounts() async throws -> [Account] {
        testAccounts.filter { $0.isActive }
    }
    
    func getAccount(byId id: UUID) async throws -> Account {
        if let acc = testAccounts.first(where: { $0.id == id }) {
            return acc
        }
        throw AccountError.accountNotFound
    }
    
    func deleteAccount(_ id: UUID) async throws {
        testAccounts.removeAll { $0.id == id }
    }
    
    func deactivateAccount(_ id: UUID, isActive: Bool) async throws {
        guard let index = testAccounts.firstIndex(where: { $0.id == id }) else {
            throw AccountError.accountNotFound
        }
        testAccounts[index].isActive = isActive
    }
    
    func getAccountBalance(_ id: UUID) async throws -> Decimal {
        guard let acc = testAccounts.first(where: { $0.id == id }) else {
            throw AccountError.accountNotFound
        }
        return acc.currentBalance!.decimalValue
    }
}
