//
//  FormComponents.swift
//  ExpenseTracker
//
//  Created by sachinthya sunirma rathnavibushana on 2025-04-24.
//

import SwiftUI

struct FormComponents {
    
    static func customPicker(title: String, selection: Binding<String>, options: [String]) -> some View {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
                
                Menu {
                    Picker(selection: selection, label: EmptyView()) {
                        ForEach(options, id: \.self) { option in
                            Text(option).tag(option)
                        }
                    }
                } label: {
                    HStack {
                        Text(selection.wrappedValue)
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundColor(.gray)
                    }
                    .padding(16)
                    .background(Color(hex: "F5F5F5"))
                    .cornerRadius(12)
                }
            }
        }
    
    static func cardPreviewView(
            name: String,
            balance: String,
            currency: String,
            formatCurrency: (String) -> String
        ) -> some View {
            VStack(alignment: .leading, spacing: 5) {
                // Card title
                Text(name.isEmpty ? "New Account" : name)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
                
                // Card balance
                HStack(alignment: .bottom, spacing: 2) {
                    Text(formatCurrency(balance))
                        .font(.system(size: 26, weight: .bold))
                    
                    Text(currency)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.gray)
                        .padding(.bottom, 5)
                }
                
                Spacer()
            }
            .padding(24)
            .frame(height: 80)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(hex: "cdf2e5"))
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
            )
            .padding(.top, 20)
        }
    
    static func headerView(title: String, dismiss: @escaping () -> Void) -> some View {
        HStack {
            Button(action: dismiss) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.black)
            }
            
            Spacer()
            
            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
            
            Spacer()
            
            Button(action: dismiss) {
                Text("Cancel")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 15)
        .padding(.bottom, 15)
        .background(Color.white)
    }
    
    
    static func sectionView<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.black)
            
            VStack(spacing: 16) {
                content()
            }
            .padding(20)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }
    
    static func inputField(title: String, text: Binding<String>, placeholder: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.gray)
            
            TextField(placeholder, text: text)
                .font(.system(size: 17))
                .padding(16)
                .background(Color(hex: "F5F5F5"))
                .cornerRadius(12)
        }
    }
    
    static func customPicker<T: Hashable>(title: String, selection: Binding<T>, options: [T]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.gray)
            
            Menu {
                ForEach(options, id: \.self) { option in
                    Button(action: {
                        selection.wrappedValue = option
                    }) {
                        Text(String(describing: option))
                            .font(.system(size: 17))
                    }
                }
            } label: {
                HStack {
                    Text(String(describing: selection.wrappedValue))
                        .font(.system(size: 17))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                }
                .padding(16)
                .background(Color(hex: "F5F5F5"))
                .cornerRadius(12)
            }
        }
    }
}



