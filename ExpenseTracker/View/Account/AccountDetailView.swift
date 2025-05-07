//
//  AccountDetailView.swift
//  ExpenseTracker
//
//  Created by sachinthya sunirma rathnavibushana on 2025-04-23.
//

import SwiftUI

struct AccountDetailView: View {
    let account: Account
    @ObservedObject var viewModel: AccountViewModel
    @State private var showingDeactivateAlert = false
    @Environment(\.colorScheme) var colorScheme
    
    // Custom colors
    private let backgroundColor = Color(hex: "E0F5F0")
    private let cardBackground = Color.white
    private let primaryText = Color.black
    private let secondaryText = Color(hex: "6E7882")
    private let accentColor = Color(hex: "4DBAAD")
    
    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Account Header
                    balanceCard
                    
                    // Account Details
                    accountDetailsSection
                    
                    // Status Toggle
                    statusToggleButton
                        .padding(.vertical)
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(account.name ?? "Account")
                    .font(.headline)
                    .foregroundColor(primaryText)
            }
        }
        .alert(isPresented: $showingDeactivateAlert) {
            Alert(
                title: Text(account.isActive ? "Deactivate Account" : "Activate Account"),
                message: Text("Are you sure you want to \(account.isActive ? "deactivate" : "activate") this account?"),
                primaryButton: .destructive(Text("Confirm")) {
                    toggleAccountStatus()
                },
                secondaryButton: .cancel()
            )
        }
    }

    private var balanceCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(account.type ?? "Account")
                .font(.subheadline)
                .foregroundColor(secondaryText)
            
            Text("Total Balance")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(primaryText)
            
            HStack {
                Text(formatCurrency(account.currentBalance as Decimal? ?? 0, currency: account.currency ?? "USD"))
                    .font(.system(size: 30, weight: .bold))
                
                Text(account.currency ?? "USD")
                    .font(.headline)
                    .foregroundColor(secondaryText)
                    .padding(.leading, 4)
            }
            
            Text("Last updated: \(formatDate(account.updatedAt ?? Date()))")
                .font(.caption)
                .foregroundColor(secondaryText)
                .padding(.top, 4)
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardBackground)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    private func actionButton(icon: String, title: String) -> some View {
        VStack(spacing: 8) {
            Circle()
                .fill(cardBackground)
                .frame(width: 60, height: 60)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 22))
                        .foregroundColor(accentColor)
                )
            
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(secondaryText)
        }
    }
    
    private var accountDetailsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Account Details")
                .font(.headline)
                .foregroundColor(primaryText)
            
            VStack(spacing: 16) {
                detailCard(title: "Account Type", value: account.type ?? "N/A")
                detailCard(title: "Currency", value: account.currency ?? "USD")
                detailCard(title: "Initial Balance", value: formatCurrency(account.initialBalance as Decimal? ?? 0, currency: account.currency ?? "USD"))
                detailCard(title: "Status", value: account.isActive ? "Active" : "Inactive", isActive: account.isActive)
                detailCard(title: "Created On", value: formatDate(account.createdAt ?? Date()))
            }
        }
    }
    
    private func detailCard(title: String, value: String, isActive: Bool? = nil) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14))
                    .foregroundColor(secondaryText)
                
                Text(value)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(primaryText)
            }
            
            Spacer()
            
            if let isActive = isActive {
                Circle()
                    .fill(isActive ? Color.green : Color.orange)
                    .frame(width: 10, height: 10)
            }
        }
        .padding(16)
        .background(cardBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
    }
    
    private var statusToggleButton: some View {
        Button(action: {
            showingDeactivateAlert = true
        }) {
            Text(account.isActive ? "Deactivate Account" : "Activate Account")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(account.isActive ? Color.orange : Color.green)
                .cornerRadius(16)
        }
    }
    
    private func toggleAccountStatus() {
        if let id = account.id {
            Task {
                try await viewModel.updateAccountStatus(id: id, isActive: !account.isActive)
            }
        }
    }
    
    private func formatCurrency(_ amount: Decimal, currency: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        formatter.currencySymbol = currencySymbol(for: currency)
        return formatter.string(from: amount as NSNumber) ?? "\(currency) \(amount)"
    }
    
    private func currencySymbol(for currencyCode: String) -> String {
        switch currencyCode {
        case "USD": return "$"
        case "EUR": return "€"
        case "GBP": return "£"
        case "JPY": return "¥"
        default: return currencyCode
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}
    

#Preview {
    let context = CoreDataService.shared.container.viewContext
    let account = Account.previewAccount(context: context)
    AccountDetailView(account: account, viewModel: AccountViewModel())
}
