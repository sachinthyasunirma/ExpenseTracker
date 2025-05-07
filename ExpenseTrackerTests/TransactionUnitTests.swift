//
//  TransactionUnitTests.swift
//  ExpenseTrackerTests
//
//  Created by sachinthya sunirma rathnavibushana on 2025-05-07.
//

import XCTest
@testable import ExpenseTracker
import CoreData

enum MockError: Error {
    case testError
}

class TransactionViewModelTests: XCTestCase {
    var viewModel: TransactionViewModel!
    var mockService: MockTransactionService!
    let testAccountId = UUID()
    
    override func setUp() {
        super.setUp()
        mockService = MockTransactionService()
        viewModel = TransactionViewModel(accountId: testAccountId, service: mockService)
    }
    
    override func tearDown() {
        viewModel = nil
        mockService = nil
        super.tearDown()
    }
    
    @MainActor
    func testLoadTransactionsSuccess() async {
        // Given
        let transaction = Transaction(context: NSManagedObjectContext.contextForTests())
        transaction.id = UUID()
        transaction.account = Account(context: NSManagedObjectContext.contextForTests())
        transaction.account?.id = testAccountId
        mockService.mockTransactions = [transaction]
        
        // When
        await viewModel.loadTransactions(accountId: testAccountId)
        
        // Then
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.showError)
        XCTAssertEqual(viewModel.transactions.count, 1)
        XCTAssertEqual(viewModel.transactions.first?.id, transaction.id)
    }
    
    @MainActor
    func testLoadTransactionsFailure() async {
        // Given
        mockService.shouldThrowError = true
        
        // When
        await viewModel.loadTransactions(accountId: testAccountId)
        
        // Then
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertTrue(viewModel.showError)
        XCTAssertTrue(viewModel.transactions.isEmpty)
    }
    
    @MainActor
    func testAddTransactionSuccess() async {
        // Given
        let transactionDTO = TransactionDTO(
            id: UUID(),
            amount: 100.0,
            date: Date(),
            description: "Test Description",
            isIncome: false,
            merchantName: "Test Merchant",
            status: "confirmed", // Or whatever your app uses
            receiptImagePath: nil,
            location: nil,
            currencyCode: "USD",
            exchangeRate: 1.0,
            accountId: testAccountId,
            categoryId: UUID()
        )
        
        let transaction = Transaction(context: NSManagedObjectContext.contextForTests())
        transaction.id = UUID()
        transaction.account = Account(context: NSManagedObjectContext.contextForTests())
        transaction.account?.id = testAccountId
        mockService.mockTransactions = [transaction]
        
        // When
        await viewModel.addTransaction(transactionDTO, accountId: testAccountId)
        
        // Then
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.showError)
        XCTAssertEqual(viewModel.transactions.count, 1)
    }
    
    @MainActor
    func testDeleteTransactionSuccess() async {
        // Given
        let transaction = Transaction(context: NSManagedObjectContext.contextForTests())
        transaction.id = UUID()
        transaction.account = Account(context: NSManagedObjectContext.contextForTests())
        transaction.account?.id = testAccountId
        mockService.mockTransactions = [transaction]
        await viewModel.loadTransactions(accountId: testAccountId)
        
        // When
        await viewModel.deleteTransaction(transaction, accountId: testAccountId)
        
        // Then
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.showError)
        XCTAssertTrue(viewModel.transactions.isEmpty)
    }
    
    @MainActor
    func testGetMonthlyTransactionsSuccess() async {
        // Given
        let dateComponents = DateComponents(year: 2023, month: 5)
        let date = Calendar.current.date(from: dateComponents)!
        let transaction = Transaction(context: NSManagedObjectContext.contextForTests())
        transaction.id = UUID()
        transaction.account = Account(context: NSManagedObjectContext.contextForTests())
        transaction.account?.id = testAccountId
        transaction.createdAt = date
        mockService.mockTransactions = [transaction]
        
        // When
        let result = await viewModel.getMonthlyTransactions(month: 5, year: 2023)
        
        // Then
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.showError)
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.id, transaction.id)
    }
}

// Mock TransactionService for ViewModel tests
class MockTransactionService: TransactionServiceProtocol {
    var mockTransactions: [Transaction] = []
    var shouldThrowError = false
    
    func getAllTransactions(accountId: UUID) async throws -> [Transaction] {
        if shouldThrowError { throw MockError.testError }
        return mockTransactions.filter { $0.account?.id == accountId }
    }
    
    func getTransaction(id: UUID) async throws -> Transaction? {
        if shouldThrowError { throw MockError.testError }
        return mockTransactions.first { $0.id == id }
    }
    
    func addTransaction(_ transaction: TransactionDTO) async throws {
        if shouldThrowError { throw MockError.testError }
        let newTransaction = Transaction(context: NSManagedObjectContext.contextForTests())
        newTransaction.id = UUID()
        newTransaction.amount = transaction.amount as NSDecimalNumber
        mockTransactions.append(newTransaction)
    }
    
    func removeTransaction(transaction: Transaction) async throws {
        if shouldThrowError { throw MockError.testError }
        mockTransactions.removeAll { $0.id == transaction.id }
    }
    
    func cancelTransaction(transactionId: UUID) async throws {
        if shouldThrowError { throw MockError.testError }
        guard let index = mockTransactions.firstIndex(where: { $0.id == transactionId }) else {
            throw TransactionError.transactionNotFound
        }
        mockTransactions[index].status = false
    }
    
    func updateTransaction(_ transaction: Transaction) async throws {
        if shouldThrowError { throw MockError.testError }
        guard let index = mockTransactions.firstIndex(where: { $0.id == transaction.id }) else {
            throw TransactionError.transactionNotFound
        }
        mockTransactions[index] = transaction
    }
    
    // Analytics functions
    func getTransactionsByDateRange(accountId: UUID, startDate: Date, endDate: Date) async throws -> [Transaction] {
        if shouldThrowError { throw MockError.testError }
        return mockTransactions.filter {
            $0.account?.id == accountId &&
            $0.createdAt! >= startDate &&
            $0.createdAt! <= endDate
        }
    }
    
    func getTransactionsByDate(accountId: UUID, date: Date) async throws -> [Transaction] {
        if shouldThrowError { throw MockError.testError }
        let calendar = Calendar.current
        return mockTransactions.filter { transaction in
            guard let transactionDate = transaction.createdAt else { return false }
            return transaction.account?.id == accountId &&
                   calendar.isDate(transactionDate, inSameDayAs: date)
        }
    }
    
    func getMonthlyTransactions(accountId: UUID, month: Int, year: Int) async throws -> [Transaction] {
        if shouldThrowError { throw MockError.testError }
        let calendar = Calendar.current
        return mockTransactions.filter { transaction in
            guard let date = transaction.createdAt else { return false }
            let components = calendar.dateComponents([.year, .month], from: date)
            return transaction.account?.id == accountId &&
                   components.year == year &&
                   components.month == month
        }
    }
    
    func getTransactionsByCategory(accountId: UUID, categoryId: UUID) async throws -> [Transaction] {
        if shouldThrowError { throw MockError.testError }
        return mockTransactions.filter {
            $0.account?.id == accountId &&
            $0.category?.id == categoryId
        }
    }
    
    func getAllTransactionsByCategory(categoryId: UUID) async throws -> [Transaction] {
        if shouldThrowError { throw MockError.testError }
        return mockTransactions.filter { $0.category?.id == categoryId }
    }
}


extension NSManagedObjectContext {
    static func contextForTests() -> NSManagedObjectContext {
        let container = NSPersistentContainer(name: "ExpenseTracker")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load store: \(error)")
            }
        }
        return container.viewContext
    }
}
