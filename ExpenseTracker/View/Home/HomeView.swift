//
//  HomeView.swift
//  ExpenseTracker
//
//  Created by sachinthya sunirma rathnavibushana on 2025-04-25.
//

import SwiftUI

struct HomeView: View {
    @State private var selectedTab = 0
    @EnvironmentObject private var accountViewModel: AccountViewModel
    @EnvironmentObject private var budgetViewModel: BudgetViewModel
    @State private var showingAccountPicker = false
    @State private var showingAddTransaction = false
    @State private var showingSettings = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background color
                Color(hex: "F5F7FA")
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Account selection header
                    accountHeader
                        .padding(.horizontal)
                        .padding(.top, 8)
                    
                    // Main content area
                    TabView(selection: $selectedTab) {
                        DashboardView()
                            .tag(0)
                        
                        
                        
                        BudgetListView()
                            .tag(1)
                        
//                        AccountListView()
//                            .tag(2)
                        
                        if let selectedAccount = accountViewModel.selectedAccount {
                            TransactionListView(accountId: selectedAccount.id ?? UUID())
                                .tag(2)
                        } else {
                            EmptyTransactionView()
                                .tag(2)
                        }
                        
                        
                        
                        if let selectedAccount = accountViewModel.selectedAccount {
//                            AnalyticsView(accountId: selectedAccount.id ?? UUID())
//                                .tag(3)
                        } else {
                            EmptyAnalyticsView()
                                .tag(3)
                        }
                        
                        
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    
                    // Custom tab bar
                    footerTabs
                }
            }
            .task {
                await loadData()
            }
            .sheet(isPresented: $showingAccountPicker) {
                AccountSelectionView(
                    accounts: accountViewModel.accounts,
                    selectedAccount: $accountViewModel.selectedAccount
                )
            }
            .sheet(isPresented: $showingAddTransaction) {
                if let selectedAccount = accountViewModel.selectedAccount {
//                    AddTransactionView(accountId: selectedAccount.id ?? UUID())
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
        }
    }
    
    private func loadData() async {
        do {
            try await accountViewModel.loadAccounts()
            // Ensure we have a selected account after loading
            if accountViewModel.selectedAccount == nil {
                accountViewModel.selectedAccount = accountViewModel.accounts.first
            }
            
            // Print selected account details
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
    
    private var accountHeader: some View {
        HStack {
            if let selectedAccount = accountViewModel.selectedAccount {
                Button(action: { showingAccountPicker = true }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(selectedAccount.name ?? "Account")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.black)
                            
                            Text("\(selectedAccount.currentBalance?.formattedCurrency(currencyCode: selectedAccount.currency ?? "USD") ?? "")")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                        
                        Image(systemName: "chevron.down")
                            .foregroundColor(.gray)
                    }
                }
            } else {
                Button("Select Account", action: { showingAccountPicker = true })
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(hex: "45A87E"))
            }
            
            Spacer()
            
            Button(action: { showingSettings = true } ){
                Image(systemName: "gearshape")
                    .font(.system(size: 20))
                    .foregroundColor(Color(hex: "45A87E"))
                    .frame(width: 40, height: 40)
                    .background(Color(hex: "E8F5F0"))
                    .clipShape(Circle())
            }
        }
    }
    
    private var footerTabs: some View {
        HStack(spacing: 0) {
            TabButton(
                icon: "house.fill",
                label: "Home",
                isSelected: selectedTab == 0
            ) {
                selectedTab = 0
            }
            
            TabButton(
                icon: "chart.pie.fill",
                label: "Budgets",
                isSelected: selectedTab == 1
            ) {
                selectedTab = 1
            }
            
            // Central add button
            Button(action: {
                showingAddTransaction = true
            }) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 44))
                    .foregroundColor(Color(hex: "45A87E"))
                    .frame(width: 56, height: 56)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                    .offset(y: -20)
            }
            .frame(maxWidth: .infinity)
            
            TabButton(
                icon: "arrow.left.arrow.right",
                label: "Transactions",
                isSelected: selectedTab == 2
            ) {
                selectedTab = 2
            }
            
            TabButton(
                icon: "chart.line.uptrend.xyaxis",
                label: "Analytics",
                isSelected: selectedTab == 3
            ) {
                selectedTab = 3
            }
        }
        .frame(height: 70)
        .background(Color.white)
        .overlay(Divider(), alignment: .top)
    }
}

struct EmptyTransactionView: View {
    var body: some View {
        VStack {
            Spacer()
            Text("No Account Selected")
                .font(.title2)
                .foregroundColor(.gray)
            Text("Please select an account to view transactions")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.top, 4)
            Spacer()
        }
    }
}

struct EmptyAnalyticsView: View {
    var body: some View {
        VStack {
            Spacer()
            Text("No Account Selected")
                .font(.title2)
                .foregroundColor(.gray)
            Text("Please select an account to view analytics")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.top, 4)
            Spacer()
        }
    }
}

struct TabButton: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 22, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? Color(hex: "45A87E") : .gray)
                
                Text(label)
                    .font(.system(size: 12))
                    .foregroundColor(isSelected ? Color(hex: "45A87E") : .gray)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
    }
}

extension NSDecimalNumber {
    func formattedCurrency(currencyCode: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        return formatter.string(from: self) ?? ""
    }
}

#Preview {
    HomeView()
        .environment(\.managedObjectContext, CoreDataService.shared.context)
        .environmentObject(AccountViewModel(accountService: DefaultAccountService()))
        .environmentObject(BudgetViewModel())
}
