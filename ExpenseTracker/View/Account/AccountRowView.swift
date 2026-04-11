//
//  AccountRowView.swift
//  ExpenseTracker
//
//  Created by sachinthya sunirma rathnavibushana on 2025-04-23.
//

import SwiftUI

struct AccountRowView: View {
    let account: Account
    
    // Icons for different account types
    private let accountTypeIcons: [String: String] = [
        "Checking": "creditcard",
        "Savings": "banknote",
        "Credit Card": "creditcard.fill",
        "Cash": "dollarsign.circle",
        "Investment": "chart.line.uptrend.xyaxis",
        "Expense": "cart"
    ]
    
    var body: some View {
        HStack(spacing: 12) {
            // Account type icon
            ZStack {
                Circle()
                    .fill(Color(hex: "E8F5F0"))
                    .frame(width: 50, height: 50)
                
                Image(systemName: accountTypeIcons[account.type ?? ""] ?? "dollarsign.circle")
                    .font(.system(size: 20))
                    .foregroundColor(Color(hex: "45A87E"))
            }
            
            // Account details
            VStack(alignment: .leading, spacing: 4) {
                Text(account.name ?? "Unnamed Account")
                    .font(.system(size: 16, weight: .semibold))
                
                Text(account.type ?? "")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Balance and status
            VStack(alignment: .trailing, spacing: 4) {
                Text(formatCurrency(account.currentBalance as Decimal? ?? 0, currency: account.currency ?? "USD"))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(getCurrencyColor(account.currentBalance as Decimal? ?? 0))
                
                // Status indicator
                HStack(spacing: 4) {
                    Circle()
                        .fill(account.isActive ? Color.green : Color.red)
                        .frame(width: 6, height: 6)
                    
                    Text(account.isActive ? "Active" : "Inactive")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    func formatCurrency(_ amount: Decimal, currency: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        return formatter.string(from: amount as NSNumber) ?? "\(currency) \(amount)"
    }
    
    func getCurrencyColor(_ amount: Decimal) -> Color {
        if amount < 0 {
            return Color(hex: "E74C3C") // Custom red
        } else if amount == 0 {
            return Color.gray
        } else {
            return Color(hex: "45A87E") // Custom green
        }
    }
}

#Preview {
    let context = CoreDataService.shared.container.viewContext
    let account = Account.previewAccount(context: context)
    return AccountRowView(account: account)
        .padding()
        .background(Color(hex: "F5F7FA"))
}
