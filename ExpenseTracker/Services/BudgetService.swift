//
//  BudgetService.swift
//  ExpenseTracker
//
//  Created by sachinthya sunirma rathnavibushana on 2025-05-06.
//

import Foundation
import CoreData

protocol BudgetService {
    func createNewBudget(name: String,
                        amountLimit: Double,
                        startDate: Date,
                        endDate: Date,
                        notifyAtPercent: Double,
                        category: UUID) async throws -> Budget
    
    func getAllBudgets() async throws -> [Budget]
    func getActiveBudgets() async throws -> [Budget]
    func getCurrentBudgets() async throws -> [Budget]
    func getBudget(byId id: UUID) async throws -> Budget
    func getBudgets(for category: Category) async throws -> [Budget]
    
    func updateBudget(_ budget: Budget) async throws
    func deleteBudget(_ id: UUID) async throws
}

class DefaultBudgetService: BudgetService {
    
    private let budgetRepository: BudgetRepositoryProtocol
    private let categoryRepository: CategoryRepositoryProtocol
    
    init(categoryRepository: CategoryRepositoryProtocol = CategoryRepository(),
        budgetRepository: BudgetRepositoryProtocol = BudgetRepository()) {
        self.categoryRepository = categoryRepository
        self.budgetRepository = budgetRepository
    }
    
    func createNewBudget(name: String,
                         amountLimit: Double,
                         startDate: Date,
                         endDate: Date,
                         notifyAtPercent: Double,
                         category: UUID) async throws -> Budget {
        guard !name.isEmpty else {
            throw BudgetError.creationFailed
        }
        
        guard amountLimit > 0 else {
            throw BudgetError.invalidAmount
        }
        
        guard startDate < endDate else {
            throw BudgetError.invalidDateRange
        }
        
        guard (0...100).contains(notifyAtPercent) else {
            throw BudgetError.invalidAmount
        }
        
        let category = try await categoryRepository.fetchCategory(catergoryId: category)
        
        return try await budgetRepository.saveBudget(
            name: name,
            amountLimit: amountLimit,
            startDate: startDate,
            endDate: endDate,
            notifyAtPercent: notifyAtPercent,
            category: category
        )
    }
    
    func getAllBudgets() async throws -> [Budget] {
        return try await budgetRepository.fetchBudgets()
    }
    
    func getActiveBudgets() async throws -> [Budget] {
        return try await budgetRepository.fetchActiveBudgets()
    }
    
    func getCurrentBudgets() async throws -> [Budget] {
        return try await budgetRepository.fetchCurrentBudgets()
    }
    
    func getBudget(byId id: UUID) async throws -> Budget {
        guard let budget = try await budgetRepository.fetchBudget(id: id) else {
            throw BudgetError.budgetNotFound
        }
        return budget
    }
    
    func getBudgets(for category: Category) async throws -> [Budget] {
        return try await budgetRepository.fetchBudgets(for: category)
    }
    
    func updateBudget(_ budget: Budget) async throws {
        try await budgetRepository.updateBudget(budget: budget)
    }
    
    func deleteBudget(_ id: UUID) async throws {
        let budget = try await getBudget(byId: id)
        try await budgetRepository.deleteBudget(budget: budget)
    }
}
