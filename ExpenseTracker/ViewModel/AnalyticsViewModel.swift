////
////  AnalyticsViewModel.swift
////  ExpenseTracker
////
////  Created by sachinthya sunirma rathnavibushana on 2025-05-05.
////
//
//import Foundation
//
//class AnalyticsViewModel: ObservableObject {
//    @Published var selectedPeriod: AnalyticsPeriod = .month
//    @Published var isLoading = false
//    @Published var errorMessage: String?
//    
//    // Data for charts
//    @Published var spendingData: [SpendingData] = []
//    @Published var categoryData: [CategoryData] = []
//    @Published var monthlyTrendsData: [MonthlyTrendData] = []
//    
//    // Summary values
//    @Published var totalIncome: Decimal = 0
//    @Published var totalExpenses: Decimal = 0
//    @Published var netAmount: Decimal = 0
//    
//    private let transactionService: TransactionServiceProtocol
//    
//    init(transactionService: TransactionServiceProtocol = TransactionService()) {
//        self.transactionService = transactionService
//    }
//    
//    @MainActor
//    func loadAnalyticsData(accountId: UUID) async {
//        isLoading = true
//        errorMessage = nil
//        
//        do {
//            // Load all transactions for the account
//            let transactions = try await transactionService.getAllTransactions(accountId: accountId)
//            
//            // Process data for visualizations
//            processSpendingData(transactions: transactions)
//            processCategoryData(transactions: transactions)
//            processMonthlyTrends(transactions: transactions)
//            calculateSummaryValues(transactions: transactions)
//            
//        } catch {
//            errorMessage = "Failed to load analytics data: \(error.localizedDescription)"
//        }
//        
//        isLoading = false
//    }
//    
//    private func processSpendingData(transactions: [Transaction]) {
//        let calendar = Calendar.current
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "MMM d"
//        
//        // Group by day and type
//        let grouped = Dictionary(grouping: transactions) { transaction -> (Date, String) in
//            let date = transaction.date ?? Date()
//            let normalizedDate = calendar.startOfDay(for: date)
//            let type = (transaction.isIncome ? "Income" : "Expense")
//            return (normalizedDate, type)
//        }
//        
//        spendingData = grouped.map { key, values in
//            let total = values.reduce(0) { $0 + ($1.amount?.decimalValue ?? 0) }
//            return SpendingData(
//                date: key.0,
//                type: key.1,
//                amount: Double(truncating: total as NSNumber)
//            )
//        }
//    }
//    
//    private func processCategoryData(transactions: [Transaction]) {
//        // Filter only expenses
//        let expenses = transactions.filter { !$0.isIncome }
//        
//        // Group by category
//        let grouped = Dictionary(grouping: expenses) { $0.category ?? "Uncategorized" }
//        
//        let totalExpenses = expenses.reduce(0) { $0 + ($1.amount?.decimalValue ?? 0) }
//        
//        categoryData = grouped.map { name, values in
//            let sum = values.reduce(0) { $0 + ($1.amount?.decimalValue ?? 0) }
//            let percentage = totalExpenses > 0 ? Double(truncating: (sum / totalExpenses * 100) as NSNumber) : 0
//            return CategoryData(
//                name: name,
//                amount: sum,
//                percentage: percentage,
//                color: Color.random()
//            )
//        }.sorted { $0.amount > $1.amount }
//    }
//    
//    private func processMonthlyTrends(transactions: [Transaction]) {
//        let calendar = Calendar.current
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "MMM"
//        
//        // Group by month and type
//        let grouped = Dictionary(grouping: transactions) { transaction -> (String, String) in
//            let date = transaction.date ?? Date()
//            let month = calendar.component(.month, from: date)
//            let year = calendar.component(.year, from: date)
//            let monthName = dateFormatter.string(from: date)
//            let type = (transaction.isIncome ? "Income" : "Expense")
//            return ("\(monthName) \(year)", type)
//        }
//        
//        monthlyTrendsData = grouped.map { key, values in
//            let total = values.reduce(0) { $0 + ($1.amount?.decimalValue ?? 0) }
//            return MonthlyTrendData(
//                month: key.0,
//                type: key.1,
//                amount: Double(truncating: total as NSNumber)
//            )
//        }
//    }
//    
//    private func calculateSummaryValues(transactions: [Transaction]) {
//        totalIncome = transactions
//            .filter { $0.isIncome }
//            .reduce(0) { $0 + ($1.amount?.decimalValue ?? 0) }
//        
//        totalExpenses = transactions
//            .filter { !$0.isIncome }
//            .reduce(0) { $0 + ($1.amount?.decimalValue ?? 0) }
//        
//        netAmount = totalIncome - totalExpenses
//    }
//}
//
//// MARK: - Data Models
//
//enum AnalyticsPeriod: String, CaseIterable {
//    case week = "Week"
//    case month = "Month"
//    case year = "Year"
//}
//
//struct SpendingData: Identifiable {
//    let id = UUID()
//    let date: Date
//    let type: String
//    let amount: Double
//}
//
//struct CategoryData: Identifiable {
//    let id = UUID()
//    let name: String
//    let amount: Decimal
//    let percentage: Double
//    let color: Color
//}
//
//struct MonthlyTrendData: Identifiable {
//    let id = UUID()
//    let month: String
//    let type: String
//    let amount: Double
//}
//
//
//extension Decimal {
//    func formattedCurrency(currencyCode: String) -> String {
//        let formatter = NumberFormatter()
//        formatter.numberStyle = .currency
//        formatter.currencyCode = currencyCode
//        return formatter.string(from: self as NSDecimalNumber) ?? ""
//    }
//}


import Foundation
import Combine
import SwiftUI

struct CategorySummary: Identifiable {
    var id: UUID { categoryId }
    let categoryId: UUID
    let categoryName: String
    let totalAmount: Double
}

struct CategoryMonthlyData: Identifiable {
    var id: UUID { categoryId }
    let categoryId: UUID
    let categoryName: String
    let monthlyTotals: [String: Double] // month format "MMM yyyy" → amount
}

class AnalyticsViewModel: ObservableObject {
    @Published var categorySummaries: [CategorySummary] = []
    @Published var monthlyCategoryData: [CategoryMonthlyData] = []

    private var transactions: [TransactionDTO] = []
    private var categories: [CategoryDTO] = []

    init() {
//        loadMockData() // Replace with real CoreData/service loading later
    }

    func loadPieChartData(startDate: Date, endDate: Date) {
        let filtered = transactions.filter { $0.date >= startDate && $0.date <= endDate && $0.isIncome == false }
        let grouped = Dictionary(grouping: filtered, by: { $0.categoryId })

        categorySummaries = grouped.compactMap { (categoryId: UUID, transactions: [TransactionDTO]) -> CategorySummary? in
            guard let category = categories.first(where: { $0.categoryID == categoryId }) else { return nil }
            let total = transactions.reduce(Decimal(0)) { $0 + $1.amount }
            let totalAsDouble = NSDecimalNumber(decimal: total).doubleValue
            return CategorySummary(categoryId: categoryId, categoryName: category.name!, totalAmount: totalAsDouble)
        }.sorted(by: { $0.totalAmount > $1.totalAmount })
    }

    func loadLineChartData() {
        let expenses = transactions.filter { $0.isIncome == false }

        let calendar = Calendar.current
        let groupedByCategory = Dictionary(grouping: expenses, by: { $0.categoryId })

        monthlyCategoryData = groupedByCategory.compactMap { (categoryId: UUID, transactions: [TransactionDTO]) -> CategoryMonthlyData? in
            guard let category = categories.first(where: { $0.categoryID == categoryId }) else { return nil }

            var monthlyTotals: [String: Double] = [:]
            for tx in transactions {
                let monthKey = monthYearString(from: tx.date)
                monthlyTotals[monthKey, default: 0] += NSDecimalNumber(decimal: tx.amount).doubleValue
            }

            return CategoryMonthlyData(
                categoryId: categoryId,
                categoryName: category.name!,
                monthlyTotals: monthlyTotals
            )
        }
    }

    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: date)
    }

    // MARK: - TEMP MOCK DATA LOADER
//    private func loadMockData() {
//        let food = CategoryDTO(id: UUID(), name: "Food")
//        let travel = CategoryDTO(id: UUID(), name: "Travel")
//        categories = [food, travel]
//
//        transactions = [
//            TransactionDTO(id: UUID(), categoryId: food.id, amount: 2500, date: Date().addingTimeInterval(-5*24*3600), type: .expense),
//            TransactionDTO(id: UUID(), categoryId: food.id, amount: 1500, date: Date().addingTimeInterval(-25*24*3600), type: .expense),
//            TransactionDTO(id: UUID(), categoryId: travel.id, amount: 5000, date: Date().addingTimeInterval(-40*24*3600), type: .expense),
//            TransactionDTO(id: UUID(), categoryId: travel.id, amount: 2000, date: Date(), type: .expense)
//        ]
//    }
}
