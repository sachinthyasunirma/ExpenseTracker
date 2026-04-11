//
//  BudgetViewModel.swift
//  ExpenseTracker
//
//  Created by user271709 on 5/6/25.
//

import Foundation
import Combine
import SwiftUICore

class BudgetViewModel: ObservableObject {
    @Published var budgets: [Budget] = []
        @Published var isLoading = false
        @Published var errorMessage: String?
        
        private let budgetService: BudgetService
        
        init(budgetService: BudgetService = DefaultBudgetService()) {
            self.budgetService = budgetService
        }
        
        func loadBudgets() async throws {
            isLoading = true
            do {
                let budgets = try await budgetService.getAllBudgets()
                DispatchQueue.main.async {
                    self.budgets = budgets
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
                throw error
            }
        }
        
        func createBudget(
            name: String,
            amountLimit: Double,
            startDate: Date,
            endDate: Date,
            notifyAtPercent: Double,
            category: UUID?
        ) async throws {
            isLoading = true
            do {
                let budget = try await budgetService.createNewBudget(
                    name: name,
                    amountLimit: amountLimit,
                    startDate: startDate,
                    endDate: endDate,
                    notifyAtPercent: notifyAtPercent,
                    category: category!
                )
                DispatchQueue.main.async {
                    self.budgets.append(budget)
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
                throw error
            }
        }
        
        func updateBudget(_ budget: Budget) async throws {
            isLoading = true
            do {
                try await budgetService.updateBudget(budget)
                if let index = budgets.firstIndex(where: { $0.id == budget.id }) {
                    DispatchQueue.main.async {
                        self.budgets[index] = budget
                        self.isLoading = false
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
                throw error
            }
        }
        
        func deleteBudget(id: UUID) async throws {
            isLoading = true
            do {
                try await budgetService.deleteBudget(id)
                DispatchQueue.main.async {
                    self.budgets.removeAll { $0.id == id }
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
                throw error
            }
        }
        
        func spendingProgress(for budget: Budget, totalSpent: Double) -> Double {
            return min(totalSpent / budget.amountLimit, 1.0)
        }
        
        func status(for budget: Budget) -> BudgetStatus {
            let now = Date()
            
            if now < budget.startDate ?? Date() {
                return .upcoming
            } else if now > budget.endDate ?? Date() {
                return .completed
            } else {
                return .active
            }
        }
    }

    enum BudgetStatus {
        case active
        case upcoming
        case completed
        
        var color: Color {
            switch self {
            case .active: return Color(hex: "45A87E")
            case .upcoming: return Color.orange
            case .completed: return Color.gray
            }
        }
        
        var title: String {
            switch self {
            case .active: return "Active"
            case .upcoming: return "Upcoming"
            case .completed: return "Completed"
            }
        }
    }
