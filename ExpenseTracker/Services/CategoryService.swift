//
//  CategoryService.swift
//  ExpenseTracker
//
//  Created by sachinthya sunirma rathnavibushana on 2025-05-05.
//

import Foundation
import CoreData

protocol CategoryServiceProtocol {
    func fetchCategories() async throws -> [Category]
    func addCategory(name: String, colorHex: String, icon: String, budgetLimit: NSDecimalNumber?, type: String?) async throws
    func updateCategory(_ category: Category, newName: String?, newColorHex: String?, newIcon: String?, newBudgetLimit: NSDecimalNumber?, newType: String?) async throws
    func deleteCategory(_ category: Category) async throws
    func deactivateCategory(categoryId: UUID) async throws
    func getCategory(categoryId: UUID) async throws -> Category?
}

class DefaultCategoryService: CategoryServiceProtocol {
    private let repository: CategoryRepositoryProtocol
    
    init(repository: CategoryRepositoryProtocol = CategoryRepository()) {
        self.repository = repository
    }
    
    func fetchCategories() async throws -> [Category] {
        do {
            let categories = try await repository.fetchAllCategories()
            return categories.filter { $0.isActive }
        } catch {
            throw error
        }
    }
    
    func addCategory(name: String, colorHex: String, icon: String, budgetLimit: NSDecimalNumber? = nil, type: String? = nil) async throws {
        let category = Category(context: CoreDataService.shared.context)
        category.id = UUID()
        category.name = name
        category.color = colorHex
        category.icon = icon
        category.budgetLimit = budgetLimit
        category.type = type
        category.isActive = true
        category.createdAt = Date()
        category.updatedAt = Date()
        
        try await repository.saveCategory(category)
    }
    
    func updateCategory(_ category: Category, newName: String?, newColorHex: String?, newIcon: String?, newBudgetLimit: NSDecimalNumber?, newType: String?) async throws {
        if let newName = newName {
            category.name = newName
        }
        if let newColorHex = newColorHex {
            category.color = newColorHex
        }
        if let newIcon = newIcon {
            category.icon = newIcon
        }
        if let newBudgetLimit = newBudgetLimit {
            category.budgetLimit = newBudgetLimit
        }
        if let newType = newType {
            category.type = newType
        }
        category.updatedAt = Date()
        
        try await repository.updateCategory(category)
    }
    
    func deleteCategory(_ category: Category) async throws {
        try await repository.deleteCategory(category)
    }
    
    func deactivateCategory(categoryId: UUID) async throws {
        try await repository.updateCategoryById(categoryId: categoryId)
    }
    
    func getCategory(categoryId: UUID) async throws -> Category? {
        return try await repository.fetchCategory(catergoryId: categoryId)
    }
}
