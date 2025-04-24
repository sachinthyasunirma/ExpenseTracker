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
        
        var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Account Header
                    AccountHeaderView(account: account)
                    
                    // Details
                    VStack(alignment: .leading, spacing: 16) {
                        DetailRow(title: "Account Type", value: account.type ?? "N/A")
                        DetailRow(title: "Currency", value: account.currency ?? "USD")
                        DetailRow(title: "Initial Balance", value: formatCurrency(account.initialBalance as Decimal? ?? 0, currency: account.currency ?? "USD"))
                        DetailRow(title: "Current Balance", value: formatCurrency(account.currentBalance as Decimal? ?? 0, currency: account.currency ?? "USD"))
                        DetailRow(title: "Status", value: account.isActive ? "Active" : "Inactive")
                        DetailRow(title: "Created On", value: formatDate(account.createdAt ?? Date()))
                        DetailRow(title: "Last Updated", value: formatDate(account.updatedAt ?? Date()))
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // Actions
                    VStack(spacing: 16) {
                        Button(action: {
                            showingDeactivateAlert = true
                        }) {
                            HStack {
                                Image(systemName: account.isActive ? "pause.circle" : "play.circle")
                                Text(account.isActive ? "Deactivate Account" : "Activate Account")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(account.isActive ? Color.orange : Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                }
            }
            .navigationTitle("Account Details")
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
        
        private func toggleAccountStatus() {
            if let id = account.id {
                Task {
                   try await viewModel.updateAccountStatus(id: id, isActive: !account.isActive)
                }
            }
        }
        
        func formatCurrency(_ amount: Decimal, currency: String) -> String {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.currencyCode = currency
            return formatter.string(from: amount as NSNumber) ?? "\(currency) \(amount)"
        }
        
        func formatDate(_ date: Date) -> String {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            return formatter.string(from: date)
        }
    }

struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}

#Preview {
    let context = CoreDataService.shared.container.viewContext
    let account = Account.previewAccount(context: context)
    AccountDetailView(account: account, viewModel: AccountViewModel())
}
