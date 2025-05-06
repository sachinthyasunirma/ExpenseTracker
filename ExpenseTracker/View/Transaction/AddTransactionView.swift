//
//  AddTransactionView.swift
//  ExpenseTracker
//
//  Created by sachinthya sunirma rathnavibushana on 2025-05-04.
//

import SwiftUI

struct AddTransactionView: View {
    @ObservedObject var viewModel: TransactionViewModel
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var accountViewModel: AccountViewModel
    @StateObject private var categoryViewModel = CategoryViewModel()
    
    @State private var amount: String = ""
    @State private var date: Date = Date()
    @State private var description: String = ""
    @State private var isIncome: Bool = false
    @State private var merchantName: String = ""
    @State private var status: String = "Completed"
    @State private var currencyCode: String = "LKR"
    @State private var exchangeRate: String = "1.0"
    @State private var selectedCategoryId: UUID?
    
    let entryPoint: EntryPoint
    let statuses = ["Pending", "Completed", "Cancelled"]
    let currencies = ["USD", "EUR", "LKR", "GBP", "JPY", "CAD"]
    
    private var isFormValid: Bool {
        !description.isEmpty && !amount.isEmpty && selectedCategoryId != nil
    }
    
    init(viewModel: TransactionViewModel, entryPoint: EntryPoint = .general) {
        self.viewModel = viewModel
        self.entryPoint = entryPoint
    }
    
    var body: some View {
        ZStack {
            Color(hex: "E8F5F0")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                FormComponents.headerView(title: entryPoint == .income ? "Add Income" : "Add Expense", dismiss: { dismiss() })
                
                if categoryViewModel.isLoading {
                    loadingView
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
                            transactionForm
                            saveButton
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                    }
                }
            }
            
            if viewModel.isLoading {
                loadingOverlay
            }
        }
        .onAppear {
            switch entryPoint {
            case .expense:
                isIncome = false
            case .income:
                isIncome = true
            case .general:
                isIncome = false
            }
            
            Task {
                await categoryViewModel.loadCategories()
            }
        }
        .navigationBarHidden(true)
    }
    
    private var loadingView: some View {
        ProgressView("Loading Categories...")
            .padding()
    }
    
    private var transactionForm: some View {
        VStack(spacing: 24) {
            // Basic Information Section
            FormComponents.sectionView(title: "Transaction Details") {
                FormComponents.inputField(
                    title: "Description",
                    text: $description,
                    placeholder: "Enter description"
                )
                
                amountField
                
                if entryPoint == .general {
                    Toggle(isOn: $isIncome) {
                        Text("Is Income?")
                            .font(.system(size: 16))
                    }
                    .padding()
                    .background(Color(hex: "F5F5F5"))
                    .cornerRadius(12)
                }
            }
            
            // Additional Information Section
            FormComponents.sectionView(title: "Additional Information") {
                FormComponents.inputField(
                    title: "Merchant Name",
                    text: $merchantName,
                    placeholder: "e.g. Supermarket"
                )
            }
            
            FormComponents.sectionView(title: "Category") {
                FormComponents.customPicker(
                    title: "Category",
                    selection: Binding<String>(
                        get: {
                            categoryViewModel.categories.first(where: { $0.id == selectedCategoryId })?.name ?? "Select Category"
                        },
                        set: { newValue in
                            selectedCategoryId = categoryViewModel.categories.first(where: { $0.name == newValue })?.id
                        }
                    ),
                    options: ["Select Category"] + categoryViewModel.categories.map { $0.name! }
                )
            }
        }
    }
    
    private var amountField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Amount")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.gray)
            
            HStack {
                Text(currencySymbol(for: currencyCode))
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.black)
                
                TextField("0.00", text: $amount)
                    .font(.system(size: 18, weight: .medium))
                    .keyboardType(.decimalPad)
            }
            .padding(16)
            .background(Color(hex: "F5F5F5"))
            .cornerRadius(12)
        }
    }
    
    private var saveButton: some View {
        Button(action: saveTransaction) {
            Text(entryPoint == .income ? "Save Income" : "Save Expense")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    isFormValid ? Color(hex: "45A87E") : Color.gray.opacity(0.5)
                )
                .cornerRadius(16)
        }
        .disabled(!isFormValid || viewModel.isLoading)
        .padding(.top, 10)
    }
    
    private var loadingOverlay: some View {
        Color.black.opacity(0.3)
            .ignoresSafeArea()
            .overlay(
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)
            )
    }
    
    private func saveTransaction() {
        guard let categoryId = selectedCategoryId else { return }
        
        let parsedAmount = Decimal(string: amount) ?? 0
        let parsedExchangeRate = Decimal(string: exchangeRate) ?? 1.0
        let accountId = accountViewModel.selectedAccount?.id ?? UUID()
        
        let dto = TransactionDTO(
            id: UUID(),
            amount: parsedAmount,
            date: date,
            description: description,
            isIncome: isIncome,
            merchantName: merchantName,
            status: status,
            receiptImagePath: nil,
            location: nil,
            currencyCode: currencyCode,
            exchangeRate: parsedExchangeRate,
            accountId: accountId,
            categoryId: categoryId
        )
        
        Task {
            await viewModel.addTransaction(dto)
            if viewModel.errorMessage == nil {
                dismiss()
            }
        }
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
    AddTransactionView(viewModel: TransactionViewModel(accountId: UUID()), entryPoint: .general)
        .environmentObject(AccountViewModel(accountService: DefaultAccountService()))
}
