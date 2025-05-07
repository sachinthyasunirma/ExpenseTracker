//
//  BudgetListView.swift
//  ExpenseTracker
//
//  Created by user271709 on 5/6/25.
//

// BudgetListView.swift
import SwiftUI

struct BudgetListView: View {
    @EnvironmentObject var budgetViewModel: BudgetViewModel
    @State private var showingAddBudget = false
    @State private var showingErrorAlert = false
    
    var body: some View {
        ZStack {
            // Background color
            Color(hex: "F5F7FA")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                headerView
                
                if budgetViewModel.budgets.isEmpty {
                    emptyStateView
                } else {
                    budgetList
                }
            }
        }
        .sheet(isPresented: $showingAddBudget) {
            AddBudgetView()
                .environmentObject(budgetViewModel)
        }
        .task {
            await loadBudgets()
        }
        .onReceive(NotificationCenter.default.publisher(for: .transactionAdded)) { _ in
            Task {
                await loadBudgets()
            }
        }
        .onAppear {
            Task {
                await loadBudgets()
            }
        }
    }
    
    private var headerView: some View {
        HStack {
            Text("Budget")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.black)
            
            Spacer()
            
            Button(action: {
                showingAddBudget = true
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(Color(hex: "45A87E"))
                    .cornerRadius(18)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 16)
    }
    
    private func loadBudgets() async {
        do {
            try await budgetViewModel.loadBudgets()
        } catch {
            showingErrorAlert = true
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "chart.pie.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.gray.opacity(0.5))
            
            Text("No Budgets Yet")
                .font(.title3)
                .fontWeight(.medium)
            
            Text("Create and track your budgets to manage your spending better.")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var budgetList: some View {
        List {
            ForEach(budgetViewModel.budgets) { budget in
                BudgetRowView(budget: budget)
                    .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
            }
            .onDelete { indices in
                Task {
                    let budget = budgetViewModel.budgets[indices.first!]
                    try await budgetViewModel.deleteBudget(id: budget.id!)
                }
            }
        }
        .listStyle(.plain)
        .background(Color(hex: "F5F7FA"))
    }
    
    private var addButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: { showingAddBudget = true }) {
                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .padding()
                        .background(Color(hex: "45A87E"))
                        .clipShape(Circle())
                        .shadow(radius: 4)
                        .padding()
                }
            }
        }
    }
}

struct BudgetRowView: View {
    let budget: Budget
    
    var body: some View {
        let isOverBudget = budget.currentLimit > budget.amountLimit
        
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(budget.name ?? "Unnamed Budget")
                    .font(.headline)
                    .foregroundColor(.black)
                
                Spacer()
                
                Text("\(budget.amountLimit, specifier: "%.2f")")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            if budget.amountLimit > 0 {
                ProgressView(value: budget.currentLimit, total: budget.amountLimit)
                    .tint(isOverBudget ? .red : Color(hex: "45A87E"))
            } else {
                ProgressView(value: 0.0)
                    .tint(Color(hex: "45A87E"))
            }
            
            HStack {
                Text("\(budget.currentLimit, specifier: "%.2f") spent")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Text("\(max(budget.amountLimit - budget.currentLimit, 0), specifier: "%.2f") left")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            HStack {
                Text("\(budget.startDate?.formatted(date: .abbreviated, time: .omitted) ?? "") -")
                    .font(.caption2)
                    .foregroundColor(.gray)
                
                Text(budget.endDate?.formatted(date: .abbreviated, time: .omitted) ?? "")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(isOverBudget ? Color.red.opacity(0.1) : Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .onAppear {
            print(budget)
        }
    }
}



//#Preview {
//    BudgetListView()
////    BudgetListView(viewModel: BudgetViewModel())
//}


