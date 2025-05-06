//
//  TransactionListView.swift
//  ExpenseTracker
//
//  Created by sachinthya sunirma rathnavibushana on 2025-05-04.
//

import SwiftUI

struct TransactionListView: View {
    @StateObject private var viewModel: TransactionViewModel
    @State private var showingAddSheet = false
    @State private var showAlert = false
    @State private var selectedTab = "All"
    @EnvironmentObject private var accountViewModel: AccountViewModel
    
    private let tabs = ["All", "Income", "Expense"]
    
    init(accountId: UUID, transactionService: TransactionServiceProtocol = TransactionService()) {
        _viewModel = StateObject(wrappedValue: TransactionViewModel(accountId: accountId, service: transactionService))
    }
    
    var filteredTransactions: [Transaction] {
        switch selectedTab {
        case "Income":
            return viewModel.transactions.filter { $0.isIncome }
        case "Expense":
            return viewModel.transactions.filter { !$0.isIncome }
        default:
            return viewModel.transactions
        }
    }
    
    var totalAmount: String {
        let total = viewModel.transactions
            .compactMap { $0.amount?.decimalValue }
            .reduce(0, +)
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD" // Or use the account's currency
        return formatter.string(from: total as NSNumber) ?? "$\(total)"
    }
    
    var body: some View {
        ZStack {
            // Background color - matching AccountListView
            Color(hex: "F5F7FA")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom header
                headerView
                
                // Total summary card
                if !viewModel.transactions.isEmpty {
                    totalSummaryView
                }
                
                // Tab selector
                if !viewModel.transactions.isEmpty {
                    tabSelectorView
                }
                
                // Main content
                ZStack {
                    if viewModel.isLoading {
                        ProgressView()
                            .scaleEffect(1.5)
                            .padding()
                    } else if viewModel.transactions.isEmpty {
                        emptyStateView
                    } else {
                        transactionListView
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddTransactionView(viewModel: viewModel, entryPoint: .expense)
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Error"),
                message: Text(viewModel.errorMessage ?? "An error occurred"),
                dismissButton: .default(Text("OK"))
            )
        }
        .task {
            await viewModel.loadTransactions()
            await loadData()
        }
        .onChange(of: viewModel.errorMessage) { newValue in
            showAlert = newValue != nil
        }
    }
    
    private func loadData() async {
        do {
            // Print selected account details
            print(accountViewModel.selectedAccount)
            if let account = accountViewModel.selectedAccount {
                print("Selected Account after load:")
                print("Name: \(account.name ?? "N/A")")
                print("Balance: \(account.currentBalance?.formattedCurrency(currencyCode: account.currency ?? "USD") ?? "N/A")")
                print("Currency: \(account.currency ?? "N/A")")
                print("ID: \(account.id?.uuidString ?? "N/A")")
            } else {
                print("No account selected after load")
            }
        } catch {
            print("Error loading accounts: \(error)")
        }
    }
    
    private var headerView: some View {
        HStack {
            Text("Transactions")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.black)
            
            Spacer()
            
            Button(action: {
                showingAddSheet = true
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
    
    private var totalSummaryView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Total Amount")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.black)
            
            HStack(alignment: .firstTextBaseline) {
                Text(totalAmount)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.black)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
    }
    
    private var tabSelectorView: some View {
        HStack(spacing: 0) {
            ForEach(tabs, id: \.self) { tab in
                Button(action: {
                    withAnimation {
                        selectedTab = tab
                    }
                }) {
                    VStack(spacing: 8) {
                        Text(tab)
                            .font(.system(size: 16, weight: selectedTab == tab ? .semibold : .regular))
                            .foregroundColor(selectedTab == tab ? Color(hex: "45A87E") : .gray)
                        
                        // Active indicator
                        Rectangle()
                            .fill(selectedTab == tab ? Color(hex: "45A87E") : Color.clear)
                            .frame(height: 3)
                            .cornerRadius(1.5)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 8)
        .background(Color.white)
    }
    
    private var emptyStateView: some View {
        VStack {
            Spacer()
            
            Image(systemName: "list.bullet")
                .font(.system(size: 60))
                .foregroundColor(Color(hex: "E8F5F0"))
                .padding()
            
            Text("No transactions yet")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.black)
                .padding(.bottom, 8)
            
            Text("Add your first transaction to start tracking your finances")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .padding(.bottom, 24)
            
            Button(action: {
                showingAddSheet = true
            }) {
                Text("Add Your First Transaction")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(hex: "45A87E"))
                    .cornerRadius(16)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
        }
    }
    
    private var transactionListView: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                if filteredTransactions.isEmpty {
                    Text("No \(selectedTab.lowercased()) transactions")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .padding(.top, 40)
                } else {
                    ForEach(filteredTransactions, id: \.id) { transaction in
                        TransactionRowView(transaction: transaction)
                            .contextMenu {
                                Button(role: .destructive, action: {
                                    deleteTransaction(transaction)
                                }) {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
        }
    }
    
    private func deleteTransaction(_ transaction: Transaction) {
        Task {
            if let id = transaction.id {
                await viewModel.deleteTransaction(transaction)
            }
        }
    }
}

struct TransactionRowView: View {
    let transaction: Transaction
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.desc ?? "No description")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black)
                
                Text(transaction.merchantName ?? "Unknown merchant")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                
                Text(transaction.date?.formatted(date: .abbreviated, time: .omitted) ?? "")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Text(transaction.amount?.decimalValue.formatted(.currency(code: transaction.currencyCode ?? "USD")) ?? "")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(transaction.isIncome ? Color(hex: "45A87E") : .red)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    TransactionListView(accountId: UUID())
        .environment(\.managedObjectContext, CoreDataService.shared.context).environmentObject(AccountViewModel(accountService: DefaultAccountService()))
}
