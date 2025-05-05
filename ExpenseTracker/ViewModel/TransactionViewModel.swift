//
//  TransactionViewModel.swift
//  ExpenseTracker
//
//  Created by sachinthya sunirma rathnavibushana on 2025-05-04.
//

import Foundation
import SwiftUI
import CoreData

class TransactionViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false
    
    private let service: TransactionServiceProtocol
    private let accountId: UUID
    
    init(accountId: UUID, service: TransactionServiceProtocol = TransactionService()) {
        self.accountId = accountId
        self.service = service
    }
    
    @MainActor
    func loadTransactions() async {
        isLoading = true
        errorMessage = nil
        
        do {
            transactions = try await service.getAllTransactions(accountId: accountId)
        } catch {
            errorMessage = "Failed to load transactions: \(error.localizedDescription)"
            showError = true
        }
        
        isLoading = false
    }
    
    @MainActor
    func addTransaction(_ transaction: TransactionDTO) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await service.addTransaction(transaction)
            await loadTransactions()
        } catch {
            errorMessage = "Failed to add transaction: \(error.localizedDescription)"
            showError = true
        }
        
        isLoading = false
    }
    
    @MainActor
    func deleteTransaction(_ transaction: Transaction) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await service.removeTransaction(transaction: transaction)
            await loadTransactions()
        } catch {
            errorMessage = "Failed to delete transaction: \(error.localizedDescription)"
            showError = true
        }
        
        isLoading = false
    }
    
    @MainActor
    func cancelTransaction(_ transactionId: UUID) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await service.cancelTransaction(transactionId: transactionId)
            await loadTransactions()
        } catch {
            errorMessage = "Failed to cancel transaction: \(error.localizedDescription)"
            showError = true
        }
        
        isLoading = false
    }
    
    // Analytics functions
    
    @MainActor
    func getTransactionsByDateRange(startDate: Date, endDate: Date) async -> [Transaction] {
        isLoading = true
        errorMessage = nil
        
        do {
            let transactions = try await service.getTransactionsByDateRange(accountId: accountId, startDate: startDate, endDate: endDate)
            isLoading = false
            return transactions
        } catch {
            errorMessage = "Failed to get transactions: \(error.localizedDescription)"
            showError = true
            isLoading = false
            return []
        }
    }
    
    @MainActor
    func getMonthlyTransactions(month: Int, year: Int) async -> [Transaction] {
        isLoading = true
        errorMessage = nil
        
        do {
            let transactions = try await service.getMonthlyTransactions(accountId: accountId, month: month, year: year)
            isLoading = false
            return transactions
        } catch {
            errorMessage = "Failed to get monthly transactions: \(error.localizedDescription)"
            showError = true
            isLoading = false
            return []
        }
    }
}
