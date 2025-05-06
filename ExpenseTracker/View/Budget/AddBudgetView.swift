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

    @State private var name = ""
    @State private var amount = 0.0
    @State private var notifyPercent = 80.0
    @State private var startDate = Date()
    @State private var endDate = Calendar.current.date(byAdding: .month, value: 1, to: Date())!
    @State private var selectedCategoryId: UUID?

    var body: some View {
        Form {
            TextField("Name", text: $name)
            TextField("Amount Limit", text: Binding(
                get: { String(format: "%.2f", amount) },
                set: { newValue in
                    let filtered = newValue.filter { "0123456789.".contains($0) }
                    if let newAmount = Double(filtered) {
                        amount = newAmount
                    } else if filtered.isEmpty {
                        amount = 0
                    }
                }
            ))
            .keyboardType(.decimalPad)
            Slider(value: $notifyPercent, in: 50...100, step: 5) {
                Text("Notify at %")
            }
            Text("Notify when \(Int(notifyPercent))% is spent")

            DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
            DatePicker("End Date", selection: $endDate, displayedComponents: .date)
            
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

            Button("Save Budget") {
                Task {
                    try await budgetViewModel.createBudget(
                        name: name,
                        amountLimit: amount,
                        startDate: startDate,
                        endDate: endDate,
                        notifyAtPercent: notifyPercent,
                        category: selectedCategoryId
                    )
                    dismiss()
                }
            }
        }
        .onAppear {
            Task {
                await categoryViewModel.loadCategories()
            }
        }
        .navigationTitle("New Budget")
    }
}

#Preview {
    AddBudgetView()
}
