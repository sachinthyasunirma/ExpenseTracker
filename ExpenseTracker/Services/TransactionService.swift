//
//  TransactionService.swift
//  ExpenseTracker
//
//  Created by sachinthya sunirma rathnavibushana on 2025-05-03.
//

import Foundation
import CoreData

protocol TransactionServiceProtocol {
    func getAllTransactions(accountId: UUID) async throws -> [Transaction]
    func getTransaction(id: UUID) async throws -> Transaction?
    func addTransaction(_ transaction: TransactionDTO) async throws
    func removeTransaction(transaction: Transaction) async throws
    func cancelTransaction(transactionId: UUID) async throws
    func updateTransaction(_ transaction: Transaction) async throws
    
    // Analytics functions
    func getTransactionsByDateRange(accountId: UUID, startDate: Date, endDate: Date) async throws -> [Transaction]
    func getTransactionsByDate(accountId: UUID, date: Date) async throws -> [Transaction]
    func getMonthlyTransactions(accountId: UUID, month: Int, year: Int) async throws -> [Transaction]
    func getTransactionsByCategory(accountId: UUID, categoryId: UUID) async throws -> [Transaction]
    func getAllTransactionsByCategory(categoryId: UUID) async throws -> [Transaction]
}

class TransactionService: TransactionServiceProtocol {
    private let repository: TransactionProtocol
    
    init(repository: TransactionProtocol = TransactionRepository()) {
        self.repository = repository
    }
    
    func getAllTransactions(accountId: UUID) async throws -> [Transaction] {
        try await repository.fetchAllTransactions(accountId: accountId)
    }
    
    func getTransaction(id: UUID) async throws -> Transaction? {
        try await repository.fetchTransaction(id: id)
    }
    
    func addTransaction(_ transaction: TransactionDTO) async throws {
        try await repository.createTransaction(transaction)
    }
    
    func removeTransaction(transaction: Transaction) async throws {
        try await repository.deleteTransaction(transaction: transaction)
    }
    
    func cancelTransaction(transactionId: UUID) async throws {
        try await repository.updateTransactionById(transactionId: transactionId)
    }
    
    func updateTransaction(_ transaction: Transaction) async throws {
        try await repository.updateTransaction(transaction)
    }
    
    
    func getTransactionsByDateRange(accountId: UUID, startDate: Date, endDate: Date) async throws -> [Transaction] {
        try await repository.fetchTransactionsByAccountAndDateRange(accountId: accountId, startDate: startDate, endDate: endDate)
    }
    
    func getTransactionsByDate(accountId: UUID, date: Date) async throws -> [Transaction] {
        try await repository.fetchTransactionsByAccountAndDate(accountId: accountId, date: date)
    }
    
    func getMonthlyTransactions(accountId: UUID, month: Int, year: Int) async throws -> [Transaction] {
        try await repository.fetchTransactionsByAccountAndMonthAndYear(accountId: accountId, month: month, year: year)
    }
    
    func getTransactionsByCategory(accountId: UUID, categoryId: UUID) async throws -> [Transaction] {
        try await repository.fetchTransactionsByAccountAndCategory(accountId: accountId, categoryId: categoryId)
    }
    
    func getAllTransactionsByCategory(categoryId: UUID) async throws -> [Transaction] {
        try await repository.fetchTransactionsByCategory(categoryId: categoryId)
    }
}



