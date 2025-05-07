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
    @EnvironmentObject var analyticsVM: AnalyticsViewModel

    @State private var startDate: Date = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Date())) ?? Date()
    @State private var endDate: Date = Date()

    var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Time frame picker
                    VStack(alignment: .leading) {
                        Text("Time Frame")
                            .font(.caption)
                            .foregroundColor(.gray)
                        DatePicker("From", selection: $startDate, displayedComponents: .date)
                        DatePicker("To", selection: $endDate, in: startDate...Date(), displayedComponents: .date)
                        Button("Update Pie Chart") {
                            analyticsVM.loadPieChartData(startDate: startDate, endDate: endDate)
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
            .navigationTitle("Analytics")
            .onAppear {
                analyticsVM.loadPieChartData(startDate: startDate, endDate: endDate)
                analyticsVM.loadLineChartData()
            }
        
    }
}

