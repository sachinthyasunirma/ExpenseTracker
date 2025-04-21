//
//  ExpenseTrackerApp.swift
//  ExpenseTracker
//
//  Created by sachinthya sunirma rathnavibushana on 2025-04-21.
//

import SwiftUI
import SwiftData

@main
struct ExpenseTrackerApp: App {
    @AppStorage("isOnboardingCompleted") var isOnboardingCompleted: Bool = false
    let modelContainer : ModelContainer;
    
    init() {
        do{
            let schema = Schema([])
            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                allowsSave: true
            )
            
            modelContainer = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
            
        }catch{
            fatalError(error.localizedDescription)
        }
        
    }
    
    var body: some Scene {
        WindowGroup {
            if !isOnboardingCompleted {
                OnboardingView(isOnboardingCompleted : $isOnboardingCompleted)
            }else{
                ContentView()
            }
        }.modelContainer(modelContainer)
    }
}
