//
//  AccountViewModel.swift
//  ExpenseTracker
//
//  Created by sachinthya sunirma rathnavibushana on 2025-04-23.
//

import Foundation

class AccountViewModel : ObservableObject {
    @Published var accounts : [Account] = []
    @Published var errorMessage: AccountError? = nil
    @Published var isLoading : Bool = false
    
    private let accountService : AccountService
    
    init(accountService: AccountService = DefaultAccountService()) {
        self.accountService = accountService
    }
    
    @MainActor
    func loadAccounts() async throws {
        isLoading = true
        do{
            self.accounts = try await accountService.getAllAccounts();
        }catch {
            self.errorMessage = error as? AccountError
        }
        isLoading = false
    }
    
    @MainActor
    func createAccount(name: String, type: String, currency: String, initialBalance: Decimal) async throws {
        isLoading = true
        do{
            _ = try await accountService.createNewAccount(name: name, type: type, currency: currency, initialBalance: initialBalance)
            isLoading = false
        }catch{
            self.errorMessage = error as? AccountError
        }
    }
    
    @MainActor
    func deleteAccount(id: UUID) async throws {
        isLoading = true
        do{
            try await accountService.deleteAccount(id)
            isLoading = false
        }catch{
            self.errorMessage = error as? AccountError
        }
    }
    
    @MainActor
    func updateAccountStatus(id: UUID, isActive: Bool) async throws {
        isLoading = true
        do{
            try await accountService.deactivateAccount(id, isActive: isActive)
            isLoading = false
        }catch{
            self.errorMessage = error as? AccountError
        }
    }
}
