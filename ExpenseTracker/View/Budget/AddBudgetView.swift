//
//  AddBudgetView.swift
//  ExpenseTracker
//
//  Created by user271709 on 5/6/25.
//

import SwiftUI

struct AddBudgetView: View {
    @EnvironmentObject var budgetViewModel: BudgetViewModel
    @StateObject private var categoryViewModel = CategoryViewModel()
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var accountViewModel: AccountViewModel
    
    @State private var name = ""
    @State private var amount = ""
    @State private var notifyPercent = 80.0
    @State private var startDate = Date()
    @State private var endDate = Calendar.current.date(byAdding: .month, value: 1, to: Date())!
    @State private var selectedCategoryId: UUID?
    @State private var isCategoryPickerShown = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Budget Name
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Budget Name")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        TextField("e.g., Groceries, Entertainment", text: $name)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.body)
                    }
                    .padding(.horizontal)
                    
                    // Amount Limit
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Amount Limit")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        HStack {
                            if let selectedAccount = accountViewModel.selectedAccount {
                                Text(selectedAccount.currency!)
                            } else {
                                Text("USD")
                                    .foregroundColor(.gray)
                            }
                            
                            TextField("0.00", text: $amount)
                                .keyboardType(.decimalPad)
                                .font(.body)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                    }
                    .padding(.horizontal)
                    
                    // Notification Settings
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Notification Settings")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        VStack(spacing: 8) {
                            HStack {
                                Text("Notify when spent:")
                                Spacer()
                                Text("\(Int(notifyPercent))%")
                                    .foregroundColor(Color(hex: "45A87E"))
                                    .fontWeight(.medium)
                            }
                            
                            Slider(value: $notifyPercent, in: 50...100, step: 5)
                                .accentColor(Color(hex: "45A87E"))
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                    }
                    .padding(.horizontal)
                    
                    // Date Range
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Budget Period")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        VStack(spacing: 16) {
                            DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                                .accentColor(Color(hex: "45A87E"))
                            
                            Divider()
                            
                            DatePicker("End Date", selection: $endDate, in: startDate..., displayedComponents: .date)
                                .accentColor(Color(hex: "45A87E"))
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                    }
                    .padding(.horizontal)
                    
                    // Category Selection
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Category (Optional)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        Button(action: {
                            isCategoryPickerShown = true
                        }) {
                            HStack {
                                Text(selectedCategoryName)
                                    .foregroundColor(selectedCategoryId == nil ? .gray : .primary)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(.systemGray4), lineWidth: 1)
                            )
                        }
                        .sheet(isPresented: $isCategoryPickerShown) {
                            categorySelectionView
                        }
                    }
                    .padding(.horizontal)
                    
                    // Save Button
                    Button(action: saveBudget) {
                        Text("Save Budget")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: "45A87E"))
                            .cornerRadius(10)
                    }
                    .padding()
                    .disabled(name.isEmpty || amount.isEmpty)
                    .opacity(name.isEmpty || amount.isEmpty ? 0.6 : 1)
                }
                .padding(.vertical)
            }
            .background(Color(hex: "F5F7FA"))
            .navigationTitle("New Budget")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "45A87E"))
                }
            }
        }
        .onAppear {
            Task {
                await categoryViewModel.loadCategories()
            }
        }
    }

    
    private var selectedCategoryName: String {
        categoryViewModel.categories.first(where: { $0.id == selectedCategoryId })?.name ?? "Select Category"
    }
    
    private var categorySelectionView: some View {
        NavigationView {
            List(categoryViewModel.categories) { category in
                Button(action: {
                    selectedCategoryId = category.id
                    isCategoryPickerShown = false
                }) {
                    HStack {
                        Text(category.name ?? "Unnamed")
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        if selectedCategoryId == category.id {
                            Image(systemName: "checkmark")
                                .foregroundColor(Color(hex: "45A87E"))
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Select Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        isCategoryPickerShown = false
                    }
                    .foregroundColor(Color(hex: "45A87E"))
                }
            }
        }
    }
    
    private func saveBudget() {
        guard !name.isEmpty, !amount.isEmpty, let amountValue = Double(amount) else { return }
        
        Task {
            try await budgetViewModel.createBudget(
                name: name,
                amountLimit: amountValue,
                startDate: startDate,
                endDate: endDate,
                notifyAtPercent: notifyPercent,
                category: selectedCategoryId
            )
            dismiss()
        }
    }
}

#Preview {
    AddBudgetView().environmentObject(AccountViewModel(accountService: DefaultAccountService()))
}
