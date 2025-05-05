////
////  AddTransactionView.swift
////  ExpenseTracker
////
////  Created by sachinthya sunirma rathnavibushana on 2025-05-04.
////
//
//import SwiftUI
//
//struct AddTransactionView: View {
////    @ObservedObject var viewModel: TransactionViewModel
////    @Environment(\.dismiss) var dismiss
////    
////    @State private var description = ""
////    @State private var amount = ""
////    @State private var isIncome = false
////    @State private var merchantName = ""
////    @State private var currencyCode = "USD"
////    @State private var exchangeRate = "1.0"
////    
////    var body: some View {
////        NavigationStack {
////            Form {
////                Section {
////                    TextField("Description", text: $description)
////                    TextField("Merchant", text: $merchantName)
////                    
////                    Picker("Currency", selection: $currencyCode) {
////                        Text("USD").tag("USD")
////                        Text("EUR").tag("EUR")
////                        Text("GBP").tag("GBP")
////                    }
////                    
////                    TextField("Amount", text: $amount)
////                        .keyboardType(.decimalPad)
////                    
////                    TextField("Exchange Rate", text: $exchangeRate)
////                        .keyboardType(.decimalPad)
////                    
////                    Toggle("Is Income", isOn: $isIncome)
////                }
////                
////                Section {
////                    Button("Add Transaction") {
////                        Task {
////                            let amountDecimal = Decimal(string: amount) ?? 0
////                            let exchangeRateDecimal = Decimal(string: exchangeRate) ?? 1.0
////                            
////                            let transactionDTO = TransactionDTO(
////                                description: description,
////                                amount: amountDecimal,
////                                exchangeRate: exchangeRateDecimal,
////                                merchantName: merchantName,
////                                currencyCode: currencyCode,
////                                isIncome: isIncome,
////                                accountId: viewModel.accountId
////                            )
////                            
////                            await viewModel.addTransaction(transactionDTO)
////                            dismiss()
////                        }
////                    }
////                    .disabled(description.isEmpty || amount.isEmpty)
////                }
////            }
////            .navigationTitle("Add Transaction")
////            .toolbar {
////                ToolbarItem(placement: .cancellation) {
////                    Button("Cancel") {
////                        dismiss()
////                    }
////                }
////            }
////        }
////    }
//}
//
//#Preview {
//    AddTransactionView(viewModel: TransactionViewModel(accountId: UUID(), service: TransactionServiceProtocol), dismiss: arg, description: arg, amount: arg, isIncome: arg, merchantName: arg, currencyCode: arg, exchangeRate: arg)
//}
