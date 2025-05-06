//
//  AddBudgetView.swift
//  ExpenseTracker
//
//  Created by user271709 on 5/6/25.
//

import SwiftUI

struct AddBudgetView: View {
    @EnvironmentObject var budgetViewModel: BudgetViewModel
    @Environment(\.dismiss) var dismiss

    @State private var name = ""
    @State private var amount = ""
    @State private var notifyPercent = 80.0
    @State private var startDate = Date()
    @State private var endDate = Calendar.current.date(byAdding: .month, value: 1, to: Date())!

    var body: some View {
        Form {
            TextField("Name", text: $name)
            TextField("Amount Limit", text: $amount)
                .keyboardType(.decimalPad)
            Slider(value: $notifyPercent, in: 50...100, step: 5) {
                Text("Notify at %")
            }
            Text("Notify when \(Int(notifyPercent))% is spent")

            DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
            DatePicker("End Date", selection: $endDate, displayedComponents: .date)

            Button("Save Budget") {
                let budget = Budget(
                    id: UUID(),
                    name: name,
                    categoryID: UUID(), // To be linked with actual category
                    amountLimit: Double(amount) ?? 0,
                    startDate: startDate,
                    endDate: endDate,
                    notifyAtPercent: notifyPercent
                )
                budgetViewModel.addBudget(budget)
                dismiss()
            }
        }
        .navigationTitle("New Budget")
    }
}

#Preview {
    AddBudgetView()
}
