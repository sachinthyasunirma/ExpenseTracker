//
//  AnalyticsView.swift
//  ExpenseTracker
//
//  Created by user271709 on 5/7/25.
//

// AnalyticsView.swift
import SwiftUI
import Charts

struct AnalyticsView: View {
    let accountId: UUID
    @EnvironmentObject var analyticsVM: AnalyticsViewModel

    @State private var startDate: Date = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Date())) ?? Date()
    @State private var endDate: Date = Date()

    var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Time frame picker
                    VStack(alignment: .leading) {
                        headerView
                        Text("Time Frame")
                            .font(.caption)
                            .foregroundColor(.gray)
                        DatePicker("From", selection: $startDate, displayedComponents: .date)
                        DatePicker("To", selection: $endDate, in: startDate...Date(), displayedComponents: .date)
                        Button("Update Pie Chart") {
                            analyticsVM.loadAllData(accountId: accountId, startDate: startDate, endDate: endDate)

                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.top, 4)
                    }

                    // Pie Chart
                    if !analyticsVM.categorySummaries.isEmpty {
                        Text("Expenses by Category")
                            .font(.headline)
                        PieChartView(data: analyticsVM.categorySummaries)
                            .frame(height: 300)
                    }

                    // Line Chart
                    if !analyticsVM.monthlyCategoryData.isEmpty {
                        Text("Monthly Trends")
                            .font(.headline)
                        LineChartView(data: analyticsVM.monthlyCategoryData)
                            .frame(height: 300)
                    }
                }
                .padding()
            }
            .onAppear {
                analyticsVM.loadAllData(accountId: accountId, startDate: startDate, endDate: endDate)

            }
        
//            .onAppear {
//                // TEMP: Add fake data to test pie chart
//                let foodCategory = CategoryDTO(categoryID: UUID())
//                let travelCategory = CategoryDTO(categoryID: UUID())
//
//                analyticsVM.categories = [foodCategory, travelCategory]
//
//                analyticsVM.transactions = [
//                    TransactionDTO(id: UUID(), categoryId: foodCategory.categoryId, amount: 1200, date: Date(), isIncome: false),
//                    TransactionDTO(id: UUID(), categoryId: foodCategory.categoryId, amount: 800, date: Date(), isIncome: false),
//                    TransactionDTO(id: UUID(), categoryId: travelCategory.categoryId, amount: 3000, date: Date(), isIncome: false)
//                ]
//
//                analyticsVM.loadPieChartData(startDate: startDate, endDate: endDate)
//                analyticsVM.loadLineChartData()
//            }

        
    }
    
    private var headerView: some View {
        HStack {
            Text("Analytics")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.black)
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 16)
    }
}

