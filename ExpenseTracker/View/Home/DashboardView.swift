//
//  DashboardView.swift
//  ExpenseTracker
//
//  Created by sachinthya sunirma rathnavibushana on 2025-05-05.
//

import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @EnvironmentObject private var accountViewModel: AccountViewModel
    
    // Add state variables to control transaction sheet
    @State private var showingAddTransaction = false
    @State private var transactionEntryPoint: EntryPoint = .expense
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                if let account = accountViewModel.selectedAccount {
                    accountBalanceCard(account: account)
                } else {
                    noAccountSelectedCard
                }
                
                // Quick actions
                quickActions
                
                // Recent transactions (account-specific)
                recentTransactionsSection
                
                // Accounts summary
                accountsSection
            }
            .padding()
        }
        .task {
            await viewModel.loadDashboardData(accountId: accountViewModel.selectedAccount?.id ?? UUID())
        }
        .refreshable {
            await viewModel.loadDashboardData(accountId: accountViewModel.selectedAccount?.id ?? UUID())
        }
        // Add the sheet for adding transactions
        .sheet(isPresented: $showingAddTransaction) {
            if let selectedAccount = accountViewModel.selectedAccount {
                // Create a transaction view model
                let transactionViewModel = TransactionViewModel(accountId: selectedAccount.id ?? UUID())
                AddTransactionView(viewModel: transactionViewModel, entryPoint: transactionEntryPoint)
            } else {
                // Show message if no account is selected
                VStack {
                    Text("No account selected")
                        .font(.title2)
                    Text("Please select an account first")
                        .foregroundColor(.gray)
                    
                    Button("Close") {
                        showingAddTransaction = false
                    }
                    .padding()
                    .foregroundColor(.white)
                    .background(Color(hex: "45A87E"))
                    .cornerRadius(8)
                    .padding(.top)
                }
                .padding()
            }
        }
    }
    
    private func accountBalanceCard(account: Account) -> some View {
        // Existing code...
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(account.name ?? "Account Balance")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.gray)
                
                Spacer()
                
                Text(account.currency ?? "USD")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(account.currentBalance?.formattedCurrency(currencyCode: account.currency ?? "USD") ?? "$0.00")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.black)
            }
            
            if let accountId = account.id {
                let changeBinding = $viewModel.accountMonthlyChanges[accountId]
                let monthlyChange = changeBinding.wrappedValue

                if let monthlyChange {
                    HStack {
                        Image(systemName: monthlyChange >= 0 ? "arrow.up" : "arrow.down")
                            .foregroundColor(monthlyChange >= 0 ? Color(hex: "45A87E") : .red)

                        Text(String(format: "%.1f%% %@ from last month", abs(monthlyChange), monthlyChange >= 0 ? "increase" : "decrease"))
                            .font(.system(size: 14))
                            .foregroundColor(monthlyChange >= 0 ? Color(hex: "45A87E") : .red)
                    }
                }
            }

            Spacer().frame(height: 8)
            
            Button("View All Accounts") {
                // Navigate to accounts view
            }
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(Color(hex: "45A87E"))
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    private var noAccountSelectedCard: some View {
        // Existing code...
        VStack(spacing: 12) {
            Text("No Account Selected")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.gray)
            
            Text("Please select an account to view details")
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            Button("Select Account") {
                // Trigger account selection
            }
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(Color(hex: "45A87E"))
            .padding(.top, 8)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    private var quickActions: some View {
        HStack(spacing: 16) {
            QuickActionButton(
                icon: "arrow.down",
                label: "Income",
                color: Color(hex: "45A87E")
            ) {
                // Handle income action
                transactionEntryPoint = .income
                showingAddTransaction = true
            }
            
            QuickActionButton(
                icon: "arrow.up",
                label: "Expense",
                color: .red
            ) {
                // Handle expense action
                transactionEntryPoint = .expense
                showingAddTransaction = true
            }
            
            QuickActionButton(
                icon: "arrow.left.arrow.right",
                label: "Transfer",
                color: .blue
            ) {
                // Handle transfer action
                transactionEntryPoint = .income
                showingAddTransaction = true
            }
        }
    }
    
    // Other existing methods remain unchanged...
    private var recentTransactionsSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Recent Transactions")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
                
                Spacer()
                
                Button("See All") {
                    // Navigate to transactions
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(hex: "45A87E"))
            }
            
            if let account = accountViewModel.selectedAccount, !viewModel.recentTransactions.isEmpty {
                ForEach(viewModel.recentTransactions.prefix(5)) { transaction in
                    TransactionRowView(transaction: transaction)
                }
            } else {
                Text(accountViewModel.selectedAccount == nil ?
                     "Select an account to view transactions" :
                     "No recent transactions")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding()
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    @ViewBuilder
    private var accountRows: some View {
        ForEach(accountViewModel.accounts.prefix(3)) { account in
            AccountRowView(
                account: account
            )
        }
    }

    private var accountsSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Your Accounts")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
                
                Spacer()
                
                Button("See All") {
                    // Navigate to accounts
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(hex: "45A87E"))
            }
            
            if accountViewModel.accounts.isEmpty {
                Text("No accounts available")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding()
            } else {
                accountRows
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

struct QuickActionButton: View {
    let icon: String
    let label: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 48, height: 48)
                    .background(color)
                    .clipShape(Circle())
                
                Text(label)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.black)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

enum TimeOfDay: String {
    case morning = "morning"
    case afternoon = "afternoon"
    case evening = "evening"
    case night = "night"
    
    static var now: TimeOfDay {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 6..<12: return .morning
        case 12..<17: return .afternoon
        case 17..<22: return .evening
        default: return .night
        }
    }
}

#Preview {
    DashboardView()
        .environmentObject(AccountViewModel(accountService: DefaultAccountService()))
}
