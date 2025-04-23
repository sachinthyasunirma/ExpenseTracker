//
//  AccountView.swift
//  ExpenseTracker
//
//  Created by sachinthya sunirma rathnavibushana on 2025-04-22.
//

import SwiftUI

struct AccountView: View {
    var body: some View {
        ZStack{
            VStack(spacing: 20){
                Text("Create Account")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                Image("account_1")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
                    .foregroundColor(.blue)
                    .padding()
                TextField("Balance", text: .constant(""))
                
            }
        }
    }
}

#Preview {
    AccountView()
}
