//
//  CategoryRepository.swift
//  ExpenseTracker
//
//  Created by sachinthya sunirma rathnavibushana on 2025-05-03.
//

import Foundation
import CoreData

protocol CategoryRepositoryProtocol {
    func fetchAllCategories() async throws -> [Category]
    func saveCategory(_ category: Category) async throws
    func deleteCategory(_ category: Category) async throws
    func updateCategory(_ category: Category) async throws
    func fetchCategory(catergoryId: UUID) async throws -> Category?
    func updateCategoryById(categoryId: UUID) async throws
}

class CategoryRepository : CategoryRepositoryProtocol {
    
    private let context: NSManagedObjectContext
    
    init(
        context: NSManagedObjectContext = CoreDataService.shared.context
    ) {
        self.context = context
    }

    
    func fetchAllCategories() async throws -> [Category] {
        try await context.perform{
            let request: NSFetchRequest<Category> = Category.fetchRequest()
            return try self.context.fetch(request)
        }
    }
    
    func saveCategory(_ category: Category) async throws {
        try await context.perform {
            try self.context.save()
        }
    }
    
    func deleteCategory(_ category: Category)async throws {
        context.delete(category)
        try await context.perform {
            try self.context.save()
        }
    }
    
    func updateCategoryById(categoryId: UUID) async throws {
        guard let category = try await fetchCategory(catergoryId: categoryId) else {
            throw CategoryError.categoryNotFound
        }
        category.isActive = false
        try await updateCategory(category)
    }
    
    func updateCategory(_ category: Category) async throws {
        category.updatedAt = Date()
        try await context.perform {
            try self.context.save()
        }
    }
    
    func fetchCategory(catergoryId: UUID) async throws -> Category? {
        try await context.perform {
            let request: NSFetchRequest<Category> = Category.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", catergoryId.uuidString)
            request.fetchLimit = 1
            return try self.context.fetch(request).first
        }
    }
    
    
}

enum CategoryError : Error {
    case categoryNotFound
}
