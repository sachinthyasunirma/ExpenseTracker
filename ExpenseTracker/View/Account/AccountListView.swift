//
//  AccountListView.swift
//  ExpenseTracker
//
//  Created by sachinthya sunirma rathnavibushana on 2025-04-22.
//

import SwiftUI

struct AccountListView: View {
    @StateObject private var viewModel: AccountViewModel
    @State private var showingAddSheet = false
    @State private var showAlert = false
    
    init(accountService: AccountService = DefaultAccountService()) {
        _viewModel = StateObject(wrappedValue: AccountViewModel(accountService: accountService))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading {
                    ProgressView("Loading...")
                } else if viewModel.accounts.isEmpty {
                    VStack {
                        Spacer()
                        Text("No accounts yet")
                            .font(.headline)
                        Spacer()
                        Button("Add Your First Account") {
                            showingAddSheet = true
                        }.buttonStyle(PrimaryButtonStyle(backgroundColor: .blue))
//                        .padding()
//                        .foregroundColor(.white)
//                        .background(Color.blue)
//                        .cornerRadius(10)
//                        .padding(.top, 8)
                    }
                } else {
                    List {
                        ForEach(viewModel.accounts, id: \.id) { account in
                            NavigationLink(destination: AccountDetailView(account: account, viewModel: viewModel)) {
                                AccountRowView(account: account)
                            }
                        }
                        .onDelete(perform: deleteAccounts)
                    }
                }
            }
            .navigationTitle("Accounts")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddSheet = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AccountView(viewModel: viewModel)
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Error"),
//                    message: Text(viewModel.errorMessage ?? "Unknown error"),
                    dismissButton: .default(Text("OK"))
                )
            }
            .task {
                try! await viewModel.loadAccounts()
            }
            .onChange(of: viewModel.errorMessage) { newValue in
                showAlert = newValue != nil
            }
        }
    }
    
    func deleteAccounts(at offsets: IndexSet) {
        Task {
            for index in offsets {
                if let id = viewModel.accounts[index].id {
                    try await viewModel.deleteAccount(id: id)
                }
            }
        }
    }
}



#Preview {
    AccountListView()
}
