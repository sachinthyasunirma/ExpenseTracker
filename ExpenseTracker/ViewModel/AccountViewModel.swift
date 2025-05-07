//
//  AccountViewModel.swift
//  ExpenseTracker
//
//  Created by sachinthya sunirma rathnavibushana on 2025-04-23.
//

import Foundation
import Combine

class AccountViewModel: ObservableObject {
    @Published var accounts: [Account] = []
    @Published var selectedAccount: Account? = nil
    @Published var errorMessage: AccountError? = nil
    @Published var isLoading: Bool = false
    
    private let accountService: AccountService
    private var cancellables = Set<AnyCancellable>()
    
    init(accountService: AccountService = DefaultAccountService()) {
        self.accountService = accountService
        setupAccountSelection()
    }
    
    private func setupAccountSelection() {
        $accounts
            .sink { [weak self] accounts in
                guard let self = self else { return }
                
                // Auto-select first account if none is selected
                if self.selectedAccount == nil {
                    self.selectedAccount = accounts.first
                }
                // Ensure selected account still exists in accounts list
                else if let selectedId = self.selectedAccount?.id,
                        !accounts.contains(where: { $0.id == selectedId }) {
                    self.selectedAccount = accounts.first
                }
            }
            .store(in: &cancellables)
    }
    
    @MainActor
    func loadAccounts() async {
        isLoading = true
        errorMessage = nil
        
        do {
            self.accounts = try await accountService.getAllAccounts()
        } catch let error as AccountError {
            self.errorMessage = error
        } catch {
            self.errorMessage = .networkError(error.localizedDescription)
        }
        
        isLoading = false
    }
    
    @MainActor
    func createAccount(name: String, type: String, currency: String, initialBalance: Decimal) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let newAccount = try await accountService.createNewAccount(
                name: name,
                type: type,
                currency: currency,
                initialBalance: initialBalance
            )
            self.accounts.append(newAccount)
            self.selectedAccount = newAccount
        } catch let error as AccountError {
            self.errorMessage = error
        } catch {
            self.errorMessage = .creationFailed
        }
        
        isLoading = false
    }
    
    @MainActor
    func deleteAccount(id: UUID) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await accountService.deleteAccount(id)
            accounts.removeAll { $0.id == id }
            
            // Update selection if needed
            if selectedAccount?.id == id {
                selectedAccount = accounts.first
            }
        } catch let error as AccountError {
            self.errorMessage = error
        } catch {
            self.errorMessage = .deletionFailed
        }
        
        isLoading = false
    }
    
    @MainActor
    func updateAccountStatus(id: UUID, isActive: Bool) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await accountService.deactivateAccount(id, isActive: isActive)
            if let index = accounts.firstIndex(where: { $0.id == id }) {
                accounts[index].isActive = isActive
            }
        } catch let error as AccountError {
            self.errorMessage = error
        } catch {
            self.errorMessage = .updateFailed
        }
        
        isLoading = false
    }
    
    func getAccountById(_ id: UUID) -> Account? {
        accounts.first { $0.id == id }
    }
    
    func refreshSelectedAccount() {
        if let selectedId = selectedAccount?.id {
            selectedAccount = getAccountById(selectedId)
        }
    }
}
