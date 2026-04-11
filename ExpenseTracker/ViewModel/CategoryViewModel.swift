//
//  CategoryViewModel.swift
//  ExpenseTracker
//
//  Created by sachinthya sunirma rathnavibushana on 2025-05-05.
//

import SwiftUI
import CoreData

@MainActor
class CategoryViewModel: ObservableObject {
    @Published var categories: [Category] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let categoryService: CategoryServiceProtocol
    
    init(categoryService: CategoryServiceProtocol = DefaultCategoryService()) {
        self.categoryService = categoryService
    }
    
    func loadCategories() async {
        isLoading = true
        errorMessage = nil
        
        do {
            categories = try await categoryService.fetchCategories()
        } catch {
            errorMessage = "Failed to load categories: \(error.localizedDescription)"
            print(error)
        }
        
        isLoading = false
    }
    
    func addCategory(name: String, colorHex: String, icon: String, budgetLimit: NSDecimalNumber? = nil, type: String? = nil) async {
        do {
            try await categoryService.addCategory(
                name: name,
                colorHex: colorHex,
                icon: icon,
                budgetLimit: budgetLimit,
                type: type
            )
            await loadCategories()
        } catch {
            errorMessage = "Failed to add category: \(error.localizedDescription)"
            print(error)
        }
    }
    
    func updateCategory(_ category: Category, newName: String?, newColorHex: String?, newIcon: String?, newBudgetLimit: NSDecimalNumber?, newType: String?) async {
        do {
            try await categoryService.updateCategory(
                category,
                newName: newName,
                newColorHex: newColorHex,
                newIcon: newIcon,
                newBudgetLimit: newBudgetLimit,
                newType: newType
            )
            await loadCategories()
        } catch {
            errorMessage = "Failed to update category: \(error.localizedDescription)"
            print(error)
        }
    }
    
    func deleteCategory(_ category: Category) async {
        do {
            try await categoryService.deleteCategory(category)
            await loadCategories()
        } catch {
            errorMessage = "Failed to delete category: \(error.localizedDescription)"
            print(error)
        }
    }
    
    func deactivateCategory(categoryId: UUID) async {
        do {
            try await categoryService.deactivateCategory(categoryId: categoryId)
            await loadCategories()
        } catch {
            errorMessage = "Failed to deactivate category: \(error.localizedDescription)"
            print(error)
        }
    }
    
    func getCategory(categoryId: UUID) async -> Category? {
        do {
            return try await categoryService.getCategory(categoryId: categoryId)
        } catch {
            errorMessage = "Failed to get category: \(error.localizedDescription)"
            print(error)
            return nil
        }
    }
}
