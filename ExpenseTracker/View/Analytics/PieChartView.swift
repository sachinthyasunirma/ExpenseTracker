//
//  PieChartView.swift
//  ExpenseTracker
//
//  Created by user271709 on 5/7/25.
//

// PieChartView.swift

import SwiftUI
import Charts

struct PieChartView: View {
    let data: [CategorySummary]

    var body: some View {
        Chart(data) { item in
            SectorMark(
                angle: .value("Amount", item.totalAmount),
                innerRadius: .ratio(0.6),
                angularInset: 1
            )
            .foregroundStyle(by: .value("Category", item.categoryName))
            .annotation(position: .overlay) {
                if item.totalAmount > 0 {
                    Text(item.categoryName)
                        .font(.caption)
                        .foregroundColor(.white)
                }
            }
        }
        .chartLegend(.visible)
        .chartLegend(position: .bottom)
    }
}
