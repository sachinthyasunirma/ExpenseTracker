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
    let modelContainer = CoreDataService.shared;
    
    var body: some Scene {
        WindowGroup {
            if !isOnboardingCompleted {
                OnboardingView(isOnboardingCompleted : $isOnboardingCompleted)
                    .environment(\.managedObjectContext, modelContainer.context)
            }else if !isFirstAccountCreated && isOnboardingCompleted {
                withAnimation{
                    WelcomeView(isFirstAccountCreated: $isFirstAccountCreated)
                }
            }else{
                withAnimation{
                    AccountListView()
                }
            }
        }
    }
}
