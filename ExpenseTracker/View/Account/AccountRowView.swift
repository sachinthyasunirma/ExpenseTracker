//
//  AccountRowView.swift
//  ExpenseTracker
//
//  Created by sachinthya sunirma rathnavibushana on 2025-04-23.
//

import SwiftUI

struct AccountRowView: View {
    let account: Account
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(account.name ?? "Unnamed Account")
                    .font(.headline)
                Text(account.type ?? "")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text(formatCurrency(account.currentBalance as Decimal? ?? 0, currency: account.currency ?? "USD"))
                    .font(.headline)
                    .foregroundColor(getCurrencyColor(account.currentBalance as Decimal? ?? 0))
                
                if account.isActive {
                    Text("Active")
                        .font(.caption)
                        .padding(4)
                        .background(Color.green.opacity(0.2))
                        .cornerRadius(4)
                } else {
                    Text("Inactive")
                        .font(.caption)
                        .padding(4)
                        .background(Color.red.opacity(0.2))
                        .cornerRadius(4)
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    func formatCurrency(_ amount: Decimal, currency: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        return formatter.string(from: amount as NSNumber) ?? "\(currency) \(amount)"
    }
    
    func getCurrencyColor(_ amount: Decimal) -> Color {
        if amount < 0 {
            return .red
        } else if amount == 0 {
            return .gray
        } else {
            return .green
        }
    }
}

#Preview {
    let context = CoreDataService.shared.container.viewContext
    let account = Account.previewAccount(context: context)
    AccountRowView(account: account)
}
