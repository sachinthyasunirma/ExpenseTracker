//
//  DashboardView.swift
//  ExpenseTracker
//
//  Created by sachinthya sunirma rathnavibushana on 2025-05-05.
//

import SwiftUI

struct DashboardView: View {
    enum ActiveSheet: Identifiable {
        case addTransaction(EntryPoint)
        case accountSelection
        
        var id: String {
            switch self {
            case .addTransaction(let entryPoint):
                return "addTransaction-\(entryPoint)"
            case .accountSelection:
                return "accountSelection"
            }
        }
    }
    
    @StateObject private var viewModel = DashboardViewModel()
    @EnvironmentObject private var accountViewModel: AccountViewModel
    @State private var activeSheet: ActiveSheet?
    @State private var isSheetPresented = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let account = accountViewModel.selectedAccount {
                    accountBalanceCard(account: account)
                } else {
                    noAccountSelectedCard
                }
                
                quickActions
                recentTransactionsSection
                accountsSection
            }
            .padding()
        }
        .onReceive(NotificationCenter.default.publisher(for: .transactionAdded)) { _ in
                    Task {
                        await loadDashboardData()
                    }
                }
        .sheet(item: $activeSheet) { sheet in
            sheetView(for: sheet)
                .onAppear { isSheetPresented = true }
                .onDisappear {
                    isSheetPresented = false
                    Task { await loadDashboardData() }
                }
        }
        .task {
            await loadDashboardData()
        }
        .onChange(of: accountViewModel.selectedAccount) { _ in
            guard !isSheetPresented else { return }
            Task { await loadDashboardData() }
        }
    }
    
    @ViewBuilder
    private func sheetView(for sheet: ActiveSheet) -> some View {
        switch sheet {
        case .addTransaction(let entryPoint):
            if let selectedAccount = accountViewModel.selectedAccount {
                let transactionViewModel = TransactionViewModel(
                    accountId: selectedAccount.id ?? UUID()
                )
                AddTransactionView(
                    viewModel: transactionViewModel,
                    entryPoint: entryPoint
                )
            } else {
                noAccountSelectedSheet
            }
            
        case .accountSelection:
            AccountSelectionView(
                accounts: accountViewModel.accounts,
                selectedAccount: $accountViewModel.selectedAccount
            )
        }
    }
    
    private func loadDashboardData() async {
        await viewModel.loadDashboardData(
            accountId: accountViewModel.selectedAccount?.id ?? UUID()
        )
    }
    
    private var noAccountSelectedSheet: some View {
        VStack {
            Text("No account selected")
                .font(.title2)
            Text("Please select an account first")
                .foregroundColor(.gray)
            
            Button("Close") {
                activeSheet = nil
            }
            .buttonStyle(.borderedProminent)
            .tint(Color(hex: "45A87E"))
            .padding(.top)
        }
        .padding()
    }
    
    
    private func accountBalanceCard(account: Account) -> some View {
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
                let monthlyChange = viewModel.accountMonthlyChanges[accountId]
                
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
                activeSheet = .accountSelection
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
        VStack(spacing: 12) {
            Text("No Account Selected")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.gray)
            
            Text("Please select an account to view details")
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            Button("Select Account") {
                activeSheet = .accountSelection
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
                activeSheet = .addTransaction(.income)
            }
            
            QuickActionButton(
                icon: "arrow.up",
                label: "Expense",
                color: .red
            ) {
                activeSheet = .addTransaction(.expense)
            }
            
            QuickActionButton(
                icon: "arrow.left.arrow.right",
                label: "Transfer",
                color: .blue
            ) {
                activeSheet = .addTransaction(.income)
            }
        }
    }
    
    private var recentTransactionsSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Recent Transactions")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
                
                Spacer()
                
                Button("See All") {
                    // Navigate to transactions list
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
            AccountRowView(account: account)
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
                    activeSheet = .accountSelection
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

#Preview {
    DashboardView()
        .environmentObject(AccountViewModel(accountService: DefaultAccountService()))
}
