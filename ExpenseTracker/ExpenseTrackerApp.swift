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
    let modelContainer = CoreDataService.shared;
    
    var body: some Scene {
        WindowGroup {
            if !isOnboardingCompleted {
                OnboardingView(isOnboardingCompleted : $isOnboardingCompleted)
                    .environment(\.managedObjectContext, modelContainer.context)
            }else{
                ContentView()
            }
        }
    }
}
