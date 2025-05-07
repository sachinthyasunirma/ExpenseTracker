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
    @State private var type: String = "Savings"
    @State private var currency: String = "LKR"
    @State private var initialBalance: String = "0.00"
    @FocusState private var isBalanceFieldFocused: Bool
    
    let accountTypes = ["Checking", "Savings", "Credit Card", "Cash", "Investment", "Expense"]
    let currencies = ["USD", "EUR", "GBP", "JPY", "CAD", "AUD", "LKR"]
    
    var body: some View {
        ZStack {
            // Background color
            Color(hex: "E8F5F0")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                FormComponents.headerView(title: "Add New Account",dismiss: {dismiss()})
                
                // Main content
                ScrollView {
                    VStack(spacing: 24) {
                        // Card preview
                        FormComponents.cardPreviewView(
                            name: name,
                            balance: initialBalance,
                            currency: currency,
                            formatCurrency: formatCurrency
                        )
                        
                        // Form sections
                        formSections
                        
                        // Save button
                        saveButton
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
            
            // Loading overlay
            if viewModel.isLoading {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .overlay(
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(.white)
                    )
            }
        }
        .navigationBarHidden(true)
    }
    
    // form section
    private var formSections: some View {
        VStack(spacing: 24) {
            // Account Information
            FormComponents.sectionView(title: "Account Information") {
                FormComponents.inputField(title: "Account Name", text: $name, placeholder: "Enter account name")
                
                FormComponents.customPicker(title: "Account Type", selection: $type, options: accountTypes)
                
                FormComponents.customPicker(title: "Currency", selection: $currency, options: currencies)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Amount")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                    
                    HStack {
                        Text(currencySymbol(for: currency))
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.black)
                        
                        TextField("0.00", text: $initialBalance)
                            .font(.system(size: 18, weight: .medium))
                            .keyboardType(.decimalPad)
                            .focused($isBalanceFieldFocused)
                    }
                    .padding(16)
                    .background(Color(hex: "F5F5F5"))
                    .cornerRadius(12)
                    .onTapGesture {
                        isBalanceFieldFocused = true
                    }
                }
            }
        }
    }
    
    // save btn
    private var saveButton: some View {
        Button(action: saveAccount) {
            Text("Create Account")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    name.isEmpty ?
                    Color.gray.opacity(0.5) :
                        Color(hex: "45A87E")
                )
                .cornerRadius(16)
        }
        .disabled(name.isEmpty || viewModel.isLoading)
        .padding(.top, 10)
    }
    
    
    // save
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
    
    private func formatCurrency(amount: String) -> String {
        if let value = Double(amount) {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.minimumFractionDigits = 2
            formatter.maximumFractionDigits = 2
            return formatter.string(from: NSNumber(value: value)) ?? "0.00"
        }
        return "0.00"
    }
    
    private func currencySymbol(for currency: String) -> String {
        switch currency {
        case "USD": return "$"
        case "EUR": return "€"
        case "GBP": return "£"
        case "JPY": return "¥"
        case "CAD": return "C$"
        case "AUD": return "A$"
        case "LKR": return "Rs"
        default: return "$"
        }
    }
}

#Preview {
    AccountView(viewModel: AccountViewModel())
}
