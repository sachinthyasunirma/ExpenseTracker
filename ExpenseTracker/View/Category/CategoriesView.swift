//
//  CategoriesView.swift
//  ExpenseTracker
//
//  Created by sachinthya sunirma rathnavibushana on 2025-05-05.
//

import SwiftUI

struct CategoriesView: View {
    @StateObject private var viewModel = CategoryViewModel()
    @State private var showingAddCategory = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.categories, id: \.id) { category in
                    HStack {
                        Image(systemName: category.icon ?? "questionmark")
                            .foregroundColor(Color(hex: category.color ?? "#000000"))
                            .frame(width: 30)
                        Text(category.name ?? "Unknown")
                        Spacer()
                        if let budget = category.budgetLimit {
                            Text(budget.formattedCurrency(currencyCode: "USD"))
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .onDelete(perform: deleteCategories)
            }
            .navigationTitle("Categories")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddCategory = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddCategory) {
                AddCategoryView(viewModel: viewModel)
            }
            .task {
                await viewModel.loadCategories()
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }
    
    private func deleteCategories(at offsets: IndexSet) {
        Task {
            for index in offsets {
                let category = viewModel.categories[index]
                await viewModel.deleteCategory(category)
            }
        }
    }
}

#Preview {
    CategoriesView()
}
