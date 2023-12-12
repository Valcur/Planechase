//
//  PlanechaseApp.swift
//  Planechase
//
//  Created by Loic D on 20/02/2023.
// DICE by juicy_fish

import SwiftUI

@main
struct PlanechaseApp: App {
    @ObservedObject var planechaseVM = PlanechaseViewModel()
    
    init() {
        if #available(iOS 15, *) {
            // correct the transparency bug for Tab bars
            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithDefaultBackground()
            tabBarAppearance.backgroundColor = .black
            UITabBar.appearance().standardAppearance = tabBarAppearance
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        } else {
            UITabBar.appearance().barTintColor = .black
        }
    }

    var body: some Scene {
        WindowGroup {
            if planechaseVM.isPlaying {
                if #available(iOS 16.0, *) {
                    GameView(lifeCounterOptions: planechaseVM.lifeCounterOptions, profiles: planechaseVM.lifeCounterProfiles, planechaseVM: planechaseVM)
                        .statusBar(hidden: true)
                        .environmentObject(planechaseVM)
                        .environmentObject(planechaseVM.gameVM)
                        .ignoresSafeArea(edges: [.top, .bottom])
                        .defersSystemGestures(on: .all)
                } else {
                    GameView(lifeCounterOptions: planechaseVM.lifeCounterOptions, profiles: planechaseVM.lifeCounterProfiles, planechaseVM: planechaseVM)
                        .statusBar(hidden: true)
                        .environmentObject(planechaseVM)
                        .environmentObject(planechaseVM.gameVM)
                        .ignoresSafeArea(edges: [.top, .bottom])
                }
            } else {
                TabView {
                    MainMenuView()
                        .statusBar(hidden: true)
                        .environmentObject(planechaseVM)
                        .tabItem {
                            Image(systemName: "play.fill")
                            Text("tab_play".translate())
                        }
                    ContentManagerView()
                        .statusBar(hidden: true)
                        .environmentObject(planechaseVM)
                        .environmentObject(planechaseVM.contentManagerVM)
                        .tabItem {
                            Image(systemName: "list.dash")
                            Text("tab_collection".translate())
                        }
                    OptionsMenuView()
                        .statusBar(hidden: true)
                        .environmentObject(planechaseVM)
                        .tabItem {
                            Image(systemName: "gear")
                            Text("tab_options".translate())
                        }
                }.accentColor(.white)
                .onAppear() {
                    // Not working from init
                    IAPManager.shared.startWith(arrayOfIds: [IAPManager.getSubscriptionId(), IAPManager.getLifetimeId()], sharedSecret: IAPManager.getSharedSecret())
                    planechaseVM.testPremium()
                    UIApplication.shared.isIdleTimerDisabled = true
                }
            }
        }
    }
}
