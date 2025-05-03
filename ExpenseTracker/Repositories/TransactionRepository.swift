//
//  TransactionRepository.swift
//  ExpenseTracker
//
//  Created by sachinthya sunirma rathnavibushana on 2025-05-01.
//

import Foundation
import CoreData

protocol TransactionProtocol {
    func fetchAllTransactions(accountId: UUID) async throws -> [Transaction]
    func fetchTransaction(id: UUID) async throws -> Transaction?
    func createTransaction(_ transaction: TransactionDTO) async throws
    func deleteTransaction(transaction: Transaction) async throws
    func updateTransactionById(transactionId: UUID) async throws
    func updateTransaction(_ transaction: Transaction) async throws
    
    //Analytics operations
    func fetchTransactionsByAccountAndDateRange(accountId: UUID, startDate: Date, endDate: Date) async throws -> [Transaction]
    func fetchTransactionsByAccountAndDate(accountId: UUID, date: Date) async throws -> [Transaction]
    func fetchTransactionsByAccountAndMonthAndYear(accountId: UUID, month: Int, year: Int) async throws -> [Transaction]
    func fetchTransactionsByAccountAndCategory(accountId: UUID, categoryId: UUID) async throws -> [Transaction]
    func fetchTransactionsByCategory(categoryId: UUID) async throws -> [Transaction]
}

class TransactionRepository: TransactionProtocol {
    private let context: NSManagedObjectContext
    private let accountRepository: AccountRepositoryProtocol

    init(
        context: NSManagedObjectContext = CoreDataService.shared.context,
        accountRepository: AccountRepositoryProtocol = AccountRepository()
    ) {
        self.context = context
        self.accountRepository = accountRepository
    }

    
    func fetchAllTransactions(accountId: UUID) async throws -> [Transaction] {
        try await context.perform{
            let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
            request.predicate = NSPredicate(format: "account.id == %@",accountId  as CVarArg)
            request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
            return try self.context.fetch(request)
        }
    }
    
    func fetchTransactionsByAccountAndDateRange(accountId: UUID, startDate: Date, endDate:Date) async throws -> [Transaction] {
        try await context.perform{
            let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
            request.predicate = NSPredicate(format: "createdAt >= %@ AND createdAt <= %@", startDate as CVarArg, endDate as CVarArg)
            return try self.context.fetch(request)
        }
    }
    
    func fetchTransactionsByAccountAndCategory(accountId: UUID, categoryId: UUID) async throws -> [Transaction] {
        try await context.perform{
            let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
            request.predicate = NSPredicate(format: "account.id == %@ AND category.id == %@",accountId as CVarArg, categoryId  as CVarArg)
            return try self.context.fetch(request)
        }
    }
    
    func fetchTransactionsByCategory(categoryId: UUID) async throws -> [Transaction] {
        try await context.perform{
            let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
            request.predicate = NSPredicate(format: "category.id == %@", categoryId  as CVarArg)
            return try self.context.fetch(request)
        }
    }
    
    func fetchTransactionsByAccountAndMonthAndYear(accountId: UUID, month: Int, year: Int) async throws -> [Transaction] {
        try await context.perform{
            let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
            request.predicate = NSPredicate(format: "account.id == %@ AND createdAt CONTAINS %@", accountId as CVarArg, "\(year)-\(month)" as CVarArg)
            return try self.context.fetch(request)
        }
    }
    
    func fetchTransactionsByAccountAndDate(accountId: UUID, date: Date) async throws -> [Transaction] {
        try await context.perform{
            let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
            request.predicate = NSPredicate(format: "account.id == %@ AND createdAt CONTAINS %@",accountId as CVarArg, date as CVarArg)
            return try self.context.fetch(request)
        }
    }
    
    func fetchTransaction(id: UUID) async throws -> Transaction? {
        try await context.perform{
            let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
            request.predicate = NSPredicate(format: "id == %d", id.uuidString)
            request.fetchLimit = 1
            return try self.context.fetch(request).first
        }
    }
    
    func createTransaction(_ transactionDTO: TransactionDTO) async throws {
        let transaction = Transaction(context: context)
        transaction.id = UUID()
        transaction.desc = transactionDTO.description
        transaction.amount = transactionDTO.amount as NSDecimalNumber
        transaction.exchangeRate = transactionDTO.exchangeRate as NSDecimalNumber
        transaction.merchantName = transactionDTO.merchantName
        transaction.currencyCode = transactionDTO.currencyCode
        transaction.isIncome = transactionDTO.isIncome
        transaction.date = Date()
        transaction.status = true
        transaction.createdAt = Date()
        transaction.updatedAt = Date()

        if let account = try await accountRepository.fetchAccount(id: transactionDTO.accountId) {
            transaction.account = account

            if transactionDTO.isIncome {
                account.currentBalance = ((account.currentBalance! as Decimal) + transactionDTO.amount) as NSDecimalNumber
            } else {
                account.currentBalance = ((account.currentBalance! as Decimal) - transactionDTO.amount) as NSDecimalNumber
            }
        }

        try await context.perform {
            try self.context.save()
        }
    }

    
    func deleteTransaction(transaction: Transaction) async throws {
        context.delete(transaction)
        try await context.perform {
            try self.context.save()
        }
    }
    
    func updateTransactionById(transactionId: UUID) async throws {
        guard let transaction = try await fetchTransaction(id: transactionId) else {
            throw TransactionError.transactionNotFound
        }
        transaction.status = false
        try await updateTransaction(transaction)
    }
    
    func updateTransaction(_ transaction: Transaction) async throws {
        transaction.updatedAt = Date()
        try await context.perform {
            try self.context.save()
        }
    }
}


enum TransactionError : Error {
    case transactionNotFound
}
