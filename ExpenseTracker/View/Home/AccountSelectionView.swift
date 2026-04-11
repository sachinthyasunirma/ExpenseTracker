//
//  AccountSelectionView.swift
//  ExpenseTracker
//
//  Created by sachinthya sunirma rathnavibushana on 2025-05-05.
//

import SwiftUI

struct AccountSelectionView: View {
    let accounts: [Account]
    @Binding var selectedAccount: Account?
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List {
                ForEach(accounts, id: \.id) { account in
                    Button(action: {
                        selectedAccount = account
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(account.name ?? "Account")
                                    .font(.headline)
                                Text(account.currentBalance?.formattedCurrency(currencyCode: account.currency ?? "USD") ?? "")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            if account.id == selectedAccount?.id {
                                Image(systemName: "checkmark")
                                    .foregroundColor(Color(hex: "45A87E"))
                            }
                        }
                    }
                    .foregroundColor(.primary)
                }
            }
            .listStyle(PlainListStyle())
            .navigationTitle("Select Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    let context = CoreDataService.shared.container.viewContext
    let account = Account.previewAccount(context: context)
    
    // Create a state wrapper for the binding
    struct PreviewWrapper: View {
        @State private var selectedAccount: Account?
        let accounts: [Account]
        
        var body: some View {
            AccountSelectionView(
                accounts: accounts,
                selectedAccount: $selectedAccount
            )
        }
    }
    
    return PreviewWrapper(accounts: [account])
        .environment(\.managedObjectContext, context)
}
