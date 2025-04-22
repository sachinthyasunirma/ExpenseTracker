//
//  OnboardingView.swift
//  ExpenseTracker
//
//  Created by sachinthya sunirma rathnavibushana on 2025-04-21.
//

import SwiftUI

struct OnboardingView: View {
    @Binding var isOnboardingCompleted: Bool
    @State private var currentPage = 0
    
    let pages = [
        OnboardingPage(title: "Track Your Expenses", description: "Keep track of your daily spending habits and stay on budget.", imageName: "onboarding_1"),
        OnboardingPage(title: "Categorize Spending", description: "Organize expenses by categories to understand your spending patterns.", imageName: "onboarding_2"),
        OnboardingPage(title: "Set Financial Goals", description: "Plan your budget and achieve your financial goals.", imageName: "onboarding_3")
    ]
    
    var body: some View {
        ZStack {
            
            VStack {
                // Skip button
                HStack {
                    Spacer()
                    Button("Skip") {
                        withAnimation {
                            isOnboardingCompleted = true
                        }
                    }
                    .foregroundStyle(.green)
                    .padding()
                }
                
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        VStack(spacing: 20) {
                            Image(pages[index].imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 350, height: 350)
                                .foregroundColor(.blue)
                                .padding()
                            
                            Text(pages[index].title)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                            
                            Text(pages[index].description)
                                .font(.body)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                .onAppear{
                    UIPageControl.appearance().currentPageIndicatorTintColor = .green
                    UIPageControl.appearance().pageIndicatorTintColor = .gray
                }
                
                Button(action: {
                    if currentPage < pages.count - 1 {
                        withAnimation {
                            currentPage += 1
                        }
                    } else {
                        withAnimation {
                            isOnboardingCompleted = true
                        }
                    }
                }) {
                    Text(currentPage < pages.count - 1 ? "Next" : "Get Started")
                }
                .buttonStyle(PrimaryButtonStyle(backgroundColor: .green))
                .padding(.bottom, 50)
            }
        }
    }
}

struct OnboardingPage {
    let title: String
    let description: String
    let imageName: String
}

#Preview {
    OnboardingView(isOnboardingCompleted: .constant(false))
}
