//
//  AccountListView.swift
//  ExpenseTracker
//
//  Created by sachinthya sunirma rathnavibushana on 2025-04-22.
//

import SwiftUI

struct AccountListView: View {
    @StateObject private var viewModel: AccountViewModel
    @State private var showingAddSheet = false
    @State private var showAlert = false
    @State private var selectedTab = "All"
    
    private let tabs = ["All", "Active", "Inactive"]
    
    init(accountService: AccountService = DefaultAccountService()) {
        _viewModel = StateObject(wrappedValue: AccountViewModel(accountService: accountService))
    }
    
    var filteredAccounts: [Account] {
        switch selectedTab {
        case "Active":
            return viewModel.accounts.filter { $0.isActive }
        case "Inactive":
            return viewModel.accounts.filter { !$0.isActive }
        default:
            return viewModel.accounts
        }
    }
    
    var totalBalance: String {
        let total = viewModel.accounts
            .compactMap { $0.isActive ? $0.currentBalance as Decimal? : nil }
            .reduce(0, +)
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = viewModel.accounts[0].currency
        return formatter.string(from: total as NSNumber) ?? "USD \(total)"
    }
    
    var body: some View {
        NavigationView{
            ZStack {
                // Background color
                Color(hex: "F5F7FA")
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Custom header
                    headerView
                    
                    // Balance summary card
                    if !viewModel.accounts.isEmpty {
                        balanceSummaryView
                    }
                    
                    // Tab selector
                    if !viewModel.accounts.isEmpty {
                        tabSelectorView
                    }
                    
                    // Main content
                    ZStack {
                        if viewModel.isLoading {
                            ProgressView()
                                .scaleEffect(1.5)
                                .padding()
                        } else if viewModel.accounts.isEmpty {
                            emptyStateView
                        } else {
                            accountListView
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AccountView(viewModel: viewModel)
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Error"),
    //                message: Text(viewModel.errorMessage ?? "An error occurred"),
                    dismissButton: .default(Text("OK"))
                )
            }
            .task {
                try! await viewModel.loadAccounts()
            }
            .onChange(of: viewModel.errorMessage) { newValue in
                showAlert = newValue != nil
            }
        }
    }
    
    private var headerView: some View {
        HStack {
            Text("Accounts")
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

    private var balanceSummaryView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Total Balance")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.black)
            
            HStack(alignment: .firstTextBaseline) {
                Text(totalBalance)
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
            
            Image(systemName: "creditcard.fill")
                .font(.system(size: 60))
                .foregroundColor(Color(hex: "E8F5F0"))
                .padding()
            
            Text("No accounts yet")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.black)
                .padding(.bottom, 8)
            
            Text("Add your first account to start tracking your finances")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .padding(.bottom, 24)
            
            Button(action: {
                showingAddSheet = true
            }) {
                Text("Add Your First Account")
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
    
    private var accountListView: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                if filteredAccounts.isEmpty {
                    Text("No \(selectedTab.lowercased()) accounts")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .padding(.top, 40)
                } else {
                    ForEach(filteredAccounts, id: \.id) { account in
                        NavigationLink(destination: AccountDetailView(account: account, viewModel: viewModel)) {
                            AccountRowView(account: account)
                        }
//                        .buttonStyle(PlainButtonStyle())
                        .contextMenu {
                            Button(role: .destructive, action: {
                                deleteAccount(account)
                            }) {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            }
            .padding(.vertical, 12)
        }
    }
    
    private func actionButton(icon: String, label: String) -> some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(Color(hex: "E8F5F0"))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: "45A87E"))
            }
            
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.gray)
        }
    }
    
    private func deleteAccount(_ account: Account) {
        Task {
            if let id = account.id {
                try await viewModel.deleteAccount(id: id)
            }
        }
    }
    
    func deleteAccounts(at offsets: IndexSet) {
        Task {
            for index in offsets {
                if let id = viewModel.accounts[index].id {
                    try await viewModel.deleteAccount(id: id)
                }
            }
        }
    }
}


#Preview {
    AccountListView()
}
