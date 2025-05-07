//
//  AddCategoryView.swift
//  ExpenseTracker
//
//  Created by sachinthya sunirma rathnavibushana on 2025-05-05.
//

import SwiftUI

struct AddCategoryView: View {
    @ObservedObject var viewModel: CategoryViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var selectedColor = Color.blue
    @State private var selectedIcon = "cart"
    
    let availableIcons = ["cart", "house", "car", "airplane", "fork.knife", "film", "gamecontroller", "book", "heart", "bag"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Category Details")) {
                    TextField("Name", text: $name)
                    ColorPicker("Color", selection: $selectedColor)
                    iconPicker
                }
            }
            .navigationTitle("New Category")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            await viewModel.addCategory(
                                name: name,
                                colorHex: selectedColor.toHex(),
                                icon: selectedIcon
                            )
                            dismiss()
                        }
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private var iconPicker: some View {
        Picker("Icon", selection: $selectedIcon) {
            ForEach(availableIcons, id: \.self) { icon in
                Image(systemName: icon).tag(icon)
            }
        }
        .pickerStyle(.segmented)
    }
}

#Preview {
    AddCategoryView(viewModel: CategoryViewModel())
}
