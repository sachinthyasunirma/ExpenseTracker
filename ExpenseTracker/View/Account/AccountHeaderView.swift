//
//  AccountHeaderView.swift
//  ExpenseTracker
//
//  Created by sachinthya sunirma rathnavibushana on 2025-04-23.
//

import SwiftUI

struct AccountHeaderView: View {
    let account: Account
        
        var body: some View {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.blue.opacity(0.6)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(height: 160)
                
                VStack(alignment: .leading) {
                    HStack {
                        Text(account.name ?? "Unnamed Account")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        if !account.isActive {
                            Text("INACTIVE")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(6)
                                .background(Color.red)
                                .cornerRadius(8)
                        }
                    }
                    
                    Spacer()
                    
                    Text("Current Balance")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text(formatCurrency(account.currentBalance as Decimal? ?? 0, currency: account.currency ?? "USD"))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal)
        }
        
        func formatCurrency(_ amount: Decimal, currency: String) -> String {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.currencyCode = currency
            return formatter.string(from: amount as NSNumber) ?? "\(currency) \(amount)"
        }
    }
#Preview {
    let context = CoreDataService.shared.container.viewContext
    let account = Account.previewAccount(context: context)
    AccountHeaderView(account:account)
}
