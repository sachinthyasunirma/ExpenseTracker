//
//  AccountService.swift
//  ExpenseTracker
//
//  Created by sachinthya sunirma rathnavibushana on 2025-04-23.
//

import Foundation

protocol AccountService {
    func createNewAccount(name: String,
                          type: String,
                          currency: String,
                          initialBalance: Double) async throws -> Account
    
    func getAllAccounts() async throws -> [Account]
    func getActiveAccounts() async throws -> [Account]
    func getAccount(byId id: UUID) async throws -> Account
    
//    func updateAccountName(_ id: UUID, newName: String) async throws
//    func updateAccountType(_ id: UUID, newType: String) async throws
//    
    func deleteAccount(_ id: UUID) async throws
    func deactivateAccount(_ id: UUID, isActive: Bool) async throws
    
    func getAccountBalance(_ id: UUID) async throws -> Decimal
//    func adjustAccountBalance(_ id: UUID, amount: Double) async throws
//    func transferFunds(from sourceId: UUID,
//                       to destinationId: UUID,
//                       amount: Double) async throws
}

class DefaultAccountService : AccountService {

    private let accountRepository: AccountRepository
    
    init(accountRepository: AccountRepository) {
        self.accountRepository = accountRepository
    }
    
    func createNewAccount(name: String, type: String, currency: String, initialBalance: Double) async throws -> Account {
        guard !name.isEmpty else {
            throw AccountError.invalidAccount
        }
        
        guard initialBalance >= 0 else {
            throw AccountError.invalidAccount
        }
        
        return try await accountRepository.saveAccount(name: name, type: type, currency: currency, initialBalance: Decimal(initialBalance))
        
    }
    
    func getAllAccounts() async throws -> [Account] {
        return try await accountRepository.fetchAccounts()
    }
    
    func getActiveAccounts() async throws -> [Account] {
        return try await accountRepository.fetchActiveAccounts()
    }
    
    func getAccount(byId id: UUID) async throws -> Account {
        guard !id.uuidString.isEmpty else {
            throw AccountError.invalidAccount
        }
        return try await accountRepository.fetchAccount(id: id)!
    }
    
//    func updateAccountName(_ id: UUID, newName: String) async throws {
//        <#code#>
//    }
//    
//    func updateAccountType(_ id: UUID, newType: String) async throws {
//        <#code#>
//    }
    
    func deleteAccount(_ id: UUID) async throws {
        guard !id.uuidString.isEmpty else {
            throw AccountError.invalidAccount
        }
        try await accountRepository.deleteAccount(account: try await getAccount(byId: id))
    }
    
    func deactivateAccount(_ id: UUID, isActive: Bool) async throws {
        guard !id.uuidString.isEmpty else {
            throw AccountError.invalidAccount
        }
        try await accountRepository.updateAccountStatus(id: id, isActive: isActive)
    }
    
    func getAccountBalance(_ id: UUID) async throws -> Decimal {
        guard !id.uuidString.isEmpty else {
            throw AccountError.invalidAccount
        }
        return try await accountRepository.fetchCurrentBalance(for: id)
    }
    
//    func adjustAccountBalance(_ id: UUID, amount: Double) async throws {
//        <#code#>
//    }
//    
//    func transferFunds(from sourceId: UUID, to destinationId: UUID, amount: Double) async throws {
//        <#code#>
//    }
    
    
}
