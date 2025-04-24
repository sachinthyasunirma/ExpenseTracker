//
//  WelcomeView.swift
//  ExpenseTracker
//
//  Created by sachinthya sunirma rathnavibushana on 2025-04-21.
//

import SwiftUI

struct WelcomeView: View {
    @StateObject private var viewModel: AccountViewModel
    @State var showingAddAccountView: Bool = false
    
    @Binding var isFirstAccountCreated : Bool
    
    init(isFirstAccountCreated: Binding<Bool>,accountService: AccountService = DefaultAccountService()) {
        self._isFirstAccountCreated = isFirstAccountCreated
        _viewModel = StateObject(wrappedValue: AccountViewModel(accountService: accountService))
    }
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            VStack {
                Image("account_1")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 350, height: 350)
                    .padding()
                
                Text(viewModel.accounts.isEmpty ? "Create Account" : "Successfully Created")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                
                Text(viewModel.accounts.isEmpty
                     ? "Create your first account to manage transactions and monitor your financial progress."
                     : "Thank you! You can now start using ExpenseTracker.")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: {
                if viewModel.accounts.isEmpty {
                    withAnimation {
                        showingAddAccountView = true
                    }
                } else {
                    withAnimation {
                        isFirstAccountCreated = true
                    }
                }
            }) {
                Text(viewModel.accounts.isEmpty ? "Create Account" : "Let's Go")
            }
            .buttonStyle(PrimaryButtonStyle(backgroundColor: .green))
            .padding(.bottom, 50)
        }
        .sheet(isPresented: $showingAddAccountView) {
            AccountView(viewModel: viewModel)
        }
        .ignoresSafeArea()
    }
}

#Preview {
    WelcomeView(isFirstAccountCreated: .constant(true))
}
