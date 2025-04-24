//
//  AccountView.swift
//  ExpenseTracker
//
//  Created by sachinthya sunirma rathnavibushana on 2025-04-22.
//

import SwiftUI

struct AccountView: View {
    @ObservedObject var viewModel: AccountViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var type: String = "Checking"
    @State private var currency: String = "USD"
    @State private var initialBalance: String = "0.00"
    
    let accountTypes = ["Checking", "Savings", "Credit Card", "Cash", "Investment", "Expense"]
    let currencies = ["LKR","USD", "EUR", "GBP", "JPY", "CAD", "AUD"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Account Information")) {
                    TextField("Account Name", text: $name)
                    
                    Picker("Account Type", selection: $type) {
                        ForEach(accountTypes, id: \.self) {
                            Text($0)
                        }
                    }
                    
                    Picker("Currency", selection: $currency) {
                        ForEach(currencies, id: \.self) {
                            Text($0)
                        }
                    }
                }
                
                Section(header: Text("Balance")) {
                    TextField("Initial Balance", text: $initialBalance)
                        .keyboardType(.decimalPad)
                }
                
                Section {
                    Button("Save") {
                        saveAccount()
                    }
                    .disabled(name.isEmpty)
                }
            }
            .navigationTitle("Add Account")
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            })
            .disabled(viewModel.isLoading)
            .overlay(
                Group {
                    if viewModel.isLoading {
                        ProgressView()
                    }
                }
            )
        }
    }
    
    private func saveAccount() {
        let amount = Decimal(string: initialBalance) ?? 0
        
        Task {
            try await viewModel.createAccount(
                name: name,
                type: type,
                currency: currency,
                initialBalance: amount
            )
            
            if viewModel.errorMessage == nil {
                try await viewModel.loadAccounts()
                dismiss()
            }
        }
    }
}



#Preview {
    AccountView(viewModel: AccountViewModel())
}
