//
//  BudgetListView.swift
//  ExpenseTracker
//
//  Created by user271709 on 5/6/25.
//

// BudgetListView.swift
import SwiftUI

struct BudgetListView: View {
    @EnvironmentObject var budgetViewModel: BudgetViewModel
    @State private var showingAddBudget = false

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                if budgetViewModel.budgets.isEmpty {
                    VStack(spacing: 24) {
                        Image(systemName: "chart.pie.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.gray.opacity(0.5))

                        Text("No Budgets Yet")
                            .font(.title3)
                            .fontWeight(.medium)

                        Text("Create and track your budgets to manage your spending better.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(hex: "F5F7FA"))
                } else {
                    List {
                        ForEach(budgetViewModel.budgets) { budget in
                            VStack(alignment: .leading) {
                                Text(budget.name)
                                    .font(.headline)
                                Text("Limit: ₹\(budget.amountLimit, specifier: "%.2f")")
                                ProgressView(value: 0.5) // Replace with real value
                            }
                        }
                    }
                }

                Button(action: {
                    showingAddBudget = true
                }) {
                    Image(systemName: "plus")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.accentColor)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                }
                .padding()
                .sheet(isPresented: $showingAddBudget) {
                    AddBudgetView()
                        .environmentObject(budgetViewModel)
                }
            }
            .navigationTitle("Budgets")
        }
    }
}

struct BudgetListView_Previews: PreviewProvider {
    static var previews: some View {
        BudgetListView()
            .environmentObject(BudgetViewModel())
    }
}




//#Preview {
//    BudgetListView()
////    BudgetListView(viewModel: BudgetViewModel())
//}


