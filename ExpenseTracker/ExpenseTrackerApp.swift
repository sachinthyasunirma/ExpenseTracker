//
//  ExpenseTrackerApp.swift
//  ExpenseTracker
//
//  Created by sachinthya sunirma rathnavibushana on 2025-04-21.
//

import SwiftUI

@main
struct ExpenseTrackerApp: App {
    @AppStorage("isOnboardingCompleted") var isOnboardingCompleted: Bool = false
    @AppStorage("isFirstAccountCreated") var isFirstAccountCreated: Bool = false

    let modelContainer = CoreDataService.shared
    @StateObject private var accountViewModel = AccountViewModel()
    
    @StateObject private var budgetViewModel = BudgetViewModel()
    
    @StateObject private var analyticsViewModel = AnalyticsViewModel()

    var body: some Scene {
        WindowGroup {
            if !isOnboardingCompleted {
                OnboardingView(isOnboardingCompleted: $isOnboardingCompleted)
                    .environment(\.managedObjectContext, modelContainer.context)
                    .environmentObject(accountViewModel)
            } else if !isFirstAccountCreated {
                withAnimation {
                    WelcomeView(isFirstAccountCreated: $isFirstAccountCreated)
                        .environmentObject(accountViewModel)
                }
            } else {
                withAnimation {
                    HomeView()
                        .environmentObject(accountViewModel)
                        .environmentObject(budgetViewModel)
                        .environmentObject(analyticsViewModel)
                }
            }
        }
    }
}
