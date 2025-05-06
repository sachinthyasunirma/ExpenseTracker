//
//  BudgetViewModel.swift
//  ExpenseTracker
//
//  Created by user271709 on 5/6/25.
//

import Foundation
import Combine

class BudgetViewModel: ObservableObject {
    @Published var budgets: [Budget] = []

    func addBudget(_ budget: Budget) {
        budgets.append(budget)
    }

    func deleteBudget(id: UUID) {
        budgets.removeAll { $0.id == id }
    }

    func updateBudget(_ updatedBudget: Budget) {
        if let index = budgets.firstIndex(where: { $0.id == updatedBudget.id }) {
            budgets[index] = updatedBudget
        }
    }

    func spendingProgress(for budget: Budget, totalSpent: Double) -> Double {
        return min(totalSpent / budget.amountLimit, 1.0)
    }
}
