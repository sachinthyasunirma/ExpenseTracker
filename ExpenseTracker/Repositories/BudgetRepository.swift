//
//  BudgetRepository.swift
//  ExpenseTracker
//
//  Created by sachinthya sunirma rathnavibushana on 2025-05-06.
//

import Foundation
import CoreData

protocol BudgetRepositoryProtocol {
    func fetchBudgets() async throws -> [Budget]
    func saveBudget(name: String, amountLimit: Double, startDate: Date, endDate: Date, notifyAtPercent: Double, category: Category?) async throws -> Budget
    func fetchActiveBudgets() async throws -> [Budget]
    func fetchBudget(id: UUID) async throws -> Budget?
    func updateBudget(budget: Budget) async throws
    func deleteBudget(budget: Budget) async throws
    func fetchBudgets(for category: Category) async throws -> [Budget]
    func fetchCurrentBudgets() async throws -> [Budget]
}

class BudgetRepository: BudgetRepositoryProtocol {
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = CoreDataService.shared.context) {
        self.context = context
    }
    
    func fetchBudgets() async throws -> [Budget] {
        try await context.perform {
            let request: NSFetchRequest<Budget> = Budget.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: true)]
            return try self.context.fetch(request)
        }
    }
    
    func saveBudget(name: String, amountLimit: Double, startDate: Date, endDate: Date, notifyAtPercent: Double, category: Category?) async throws -> Budget {
        let budget = Budget(context: context)
        budget.id = UUID()
        budget.name = name
        budget.amountLimit = amountLimit
        budget.startDate = startDate
        budget.endDate = endDate
        budget.notifyAtPercent = notifyAtPercent
        budget.category = category
        
        try await context.perform {
            try self.context.save()
        }
        return budget
    }
    
    func fetchActiveBudgets() async throws -> [Budget] {
        let currentDate = Date()
        return try await context.perform {
            let request: NSFetchRequest<Budget> = Budget.fetchRequest()
            request.predicate = NSPredicate(format: "startDate <= %@ AND endDate >= %@", currentDate as NSDate, currentDate as NSDate)
            request.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: true)]
            return try self.context.fetch(request)
        }
    }
    
    func fetchBudget(id: UUID) async throws -> Budget? {
        try await context.perform {
            let request: NSFetchRequest<Budget> = Budget.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id.uuidString)
            request.fetchLimit = 1
            return try self.context.fetch(request).first
        }
    }
    
    func updateBudget(budget: Budget) async throws {
        try await context.perform {
            try self.context.save()
        }
    }
    
    func deleteBudget(budget: Budget) async throws {
        context.delete(budget)
        try await context.perform {
            try self.context.save()
        }
    }
    
    func fetchBudgets(for category: Category) async throws -> [Budget] {
        try await context.perform {
            let request: NSFetchRequest<Budget> = Budget.fetchRequest()
            request.predicate = NSPredicate(format: "category == %@", category)
            request.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: true)]
            return try self.context.fetch(request)
        }
    }
    
    func fetchCurrentBudgets() async throws -> [Budget] {
        let currentDate = Date()
        return try await context.perform {
            let request: NSFetchRequest<Budget> = Budget.fetchRequest()
            request.predicate = NSPredicate(format: "startDate <= %@ AND endDate >= %@", currentDate as NSDate, currentDate as NSDate)
            request.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: true)]
            return try self.context.fetch(request)
        }
    }
}

enum BudgetError: Error, Equatable {
    case budgetNotFound
    case invalidAmount
    case invalidDateRange
    case networkError(String)
    case unknownError
    case creationFailed
    case deletionFailed
    case updateFailed
}
