//
//  DashboardViewModel.swift
//  ExpenseTracker
//
//  Created by sachinthya sunirma rathnavibushana on 2025-05-04.
//

import Foundation
import CoreData

class DashboardViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false
    
    @Published var accountMonthlyChanges: [UUID: Double] = [:]
    @Published var recentTransactions: [Transaction] = []
    
    private let transactionService: TransactionServiceProtocol
    private let accountService: AccountService
    
    init(
        transactionService: TransactionServiceProtocol = TransactionService(),
        accountService: AccountService = DefaultAccountService()
    ) {
        self.transactionService = transactionService
        self.accountService = accountService
    }
    
    @MainActor
    func loadDashboardData(accountId: UUID?) async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Load recent transactions for all accounts
            recentTransactions = try await loadRecentTransactions(accountId: accountId)
            
            // Calculate monthly changes for all accounts
            try await calculateMonthlyChanges()
            
        } catch {
            errorMessage = "Failed to load dashboard data: \(error.localizedDescription)"
            showError = true
        }
        
        isLoading = false
    }
    
    private func loadRecentTransactions(accountId: UUID?) async throws -> [Transaction] {
        
        let transactions = try await transactionService.getAllTransactions(accountId: accountId!)
        return Array(transactions
            .sorted { ($0.date ?? Date()) > ($1.date ?? Date()) }
            .prefix(10))
    }
    
    private func calculateMonthlyChanges() async throws {
        let accounts = try await accountService.getAllAccounts()
        accountMonthlyChanges = [:]
        
        for account in accounts {
            if let accountId = account.id {
                let change = try await calculateMonthlyChange(for: accountId)
                accountMonthlyChanges[accountId] = change
            }
        }
    }
    
    private func calculateMonthlyChange(for accountId: UUID) async throws -> Double {
        let calendar = Calendar.current
        let now = Date()
        let currentMonth = calendar.component(.month, from: now)
        let currentYear = calendar.component(.year, from: now)
        
        guard let lastMonthDate = calendar.date(byAdding: .month, value: -1, to: now) else {
            return 0
        }
        let lastMonth = calendar.component(.month, from: lastMonthDate)
        let lastMonthYear = calendar.component(.year, from: lastMonthDate)
        
        // Get current month transactions
        let currentMonthTransactions = try await transactionService.getMonthlyTransactions(
            accountId: accountId,
            month: currentMonth,
            year: currentYear
        )
        let currentMonthBalance = currentMonthTransactions.reduce(0) { $0 + ($1.amount?.decimalValue ?? 0) }
        
        // Get last month transactions
        let lastMonthTransactions = try await transactionService.getMonthlyTransactions(
            accountId: accountId,
            month: lastMonth,
            year: lastMonthYear
        )
        let lastMonthBalance = lastMonthTransactions.reduce(0) { $0 + ($1.amount?.decimalValue ?? 0) }
        
        // Calculate percentage change
        guard lastMonthBalance != 0 else { return 0 }
        let change = currentMonthBalance - lastMonthBalance
        return Double(truncating: (change / lastMonthBalance * 100) as NSNumber)
    }
}
