//
//  LineChartView.swift
//  ExpenseTracker
//
//  Created by user271709 on 5/7/25.
//

// LineChartView.swift
import SwiftUI
import Charts

struct LineChartView: View {
    let data: [CategoryMonthlyData]

    var body: some View {
        Chart {
            ForEach(data) { category in
                ForEach(category.monthlyTotals.sorted(by: { $0.key < $1.key }), id: \.key) { month, total in
                    LineMark(
                        x: .value("Month", month),
                        y: .value("Amount", total)
                    )
                    .foregroundStyle(by: .value("Category", category.categoryName))
                }
            }
        }
        .chartXAxisLabel("Month")
        .chartYAxisLabel("Expense")
        .chartLegend(position: .bottom)
    }
}

