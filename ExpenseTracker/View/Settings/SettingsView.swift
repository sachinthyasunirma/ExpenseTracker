//
//  SettingsView.swift
//  ExpenseTracker
//
//  Created by sachinthya sunirma rathnavibushana on 2025-05-05.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var categoryViewModel = CategoryViewModel()
    @StateObject private var accountViewModel = AccountViewModel()
    @State private var showingAddCategory = false
    @State private var showingAddAccount = false
    @State private var newCategoryName = ""
    @State private var newCategoryColor = Color.blue
    @State private var selectedIcon = "cart"
    
    // App settings
    @AppStorage("currency") private var currency = "USD"
    @AppStorage("darkModeEnabled") private var darkModeEnabled = false
    @AppStorage("biometricAuth") private var biometricAuth = false
    
    let availableIcons = ["cart", "house", "car", "airplane", "fork.knife", "film", "gamecontroller", "book", "heart", "bag"]
    let availableCurrencies = ["USD", "EUR", "GBP", "JPY", "AUD", "CAD"]
    
    var body: some View {
        NavigationView {
            List {
                categoriesSection
                accountSection
                appSettingsSection
                aboutSection
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Settings")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
            .sheet(isPresented: $showingAddCategory) {
                AddCategoryView(viewModel: categoryViewModel)
            }
            .sheet(isPresented: $showingAddAccount){
                AccountListView()
            }
            .task {
                await categoryViewModel.loadCategories()
                await accountViewModel.loadAccounts()
            }
        }
    }
    

    private var categoriesSection: some View {
        Section(header: Text("Categories")) {
            ForEach(categoryViewModel.categories) { category in
                categoryRow(category)
            }
            .onDelete(perform: deleteCategory)
            
            addCategoryButton
        }
    }
    
    private var accountSection: some View {
        Section(header: Text("Accounts")) {
            ForEach(accountViewModel.accounts) { account in
                accountRow(account)
            }
            .onDelete(perform: deleteAccount)
            
            addAccountButton
        }
    }
    
    private var appSettingsSection: some View {
        Section(header: Text("App Settings")) {
            currencyPicker
            darkmodeToggle
            biometricToggle
        }
    }
    
    private var aboutSection: some View {
        Section(header: Text("About")) {
            versionRow
            
            NavigationLink(destination: AboutView()) {
                Text("About App")
            }
        }
    }
    
    private func accountRow(_ account: Account) -> some View {
        HStack {
            Text(account.name ?? "Unknown")
            Spacer()
        }
    }
    
    
    private func categoryRow(_ category: Category) -> some View {
        HStack {
            Image(systemName: category.icon ?? "questionmark")
                .foregroundColor(Color(hex: category.color ?? "#000000"))
                .frame(width: 30)
            Text(category.name ?? "Unknown")
            Spacer()
        }
    }
    
    private var addCategoryButton: some View {
        Button(action: { showingAddCategory = true }) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(.green)
                Text("Add New Category")
            }
        }
    }
    
    private var addAccountButton: some View {
        Button(action: { showingAddAccount = true }) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(.green)
                Text("Add New Account")
            }
        }
    }
    
    private var currencyPicker: some View {
        Picker("Currency", selection: $currency) {
            ForEach(availableCurrencies, id: \.self) { curr in
                Text(curr)
            }
        }
    }
    
    private var darkmodeToggle: some View {
        Toggle("Dark Mode", isOn: $darkModeEnabled)
    }
    
    private var biometricToggle: some View {
        Toggle("Biometric Authentication", isOn: $biometricAuth)
    }
    
    private var versionRow: some View {
        HStack {
            Text("Version")
            Spacer()
            Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")
                .foregroundColor(.gray)
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
    
    private var cancelButton: some View {
        Button("Cancel") {
            showingAddCategory = false
            newCategoryName = ""
        }
    }
    
    private func deleteAccount(at offsets: IndexSet) {
        offsets.forEach { index in
            let account = accountViewModel.accounts[index]
            Task {
                await accountViewModel.deleteAccount(id: account.id!)
            }
        }
    }
    
    private func deleteCategory(at offsets: IndexSet) {
        offsets.forEach { index in
            let category = categoryViewModel.categories[index]
            Task {
                await categoryViewModel.deleteCategory(category)
            }
        }
    }
}

struct AboutView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "dollarsign.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)
            
            Text("Expense Tracker")
                .font(.title)
                .bold()
            
            Text("Track your expenses and manage your budget effectively.")
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
        }
        .padding(.top, 40)
        .navigationTitle("About")
    }
}

struct CategoryData {
    let name: String
    let colorHex: String
    let icon: String
}

// Preview
#Preview {
    SettingsView()
        .environment(\.managedObjectContext, CoreDataService.shared.context)
}
