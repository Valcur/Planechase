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
                GameView()
                    .statusBar(hidden: true)
                    .environmentObject(planechaseVM)
                    .environmentObject(planechaseVM.gameVM)
                    .ignoresSafeArea()
            } else {
                TabView {
                    MainMenuView()
                        .statusBar(hidden: true)
                        .environmentObject(planechaseVM)
                        .tabItem {
                            Image(systemName: "play.fill")
                            Text("Play")
                        }
                    ContentManagerView()
                        .statusBar(hidden: true)
                        .environmentObject(planechaseVM)
                        .environmentObject(planechaseVM.contentManagerVM)
                        .tabItem {
                            Image(systemName: "list.dash")
                            Text("Collection")
                        }
                    OptionsMenuView()
                        .statusBar(hidden: true)
                        .environmentObject(planechaseVM)
                        .tabItem {
                            Image(systemName: "gear")
                            Text("Options")
                        }
                }
                .onAppear() {
                    // Not working from init
                    IAPManager.shared.startWith(arrayOfIds: [IAPManager.getSubscriptionId()], sharedSecret: IAPManager.getSharedSecret())
                    planechaseVM.testPremium()
                }
            }
        }
    }
}

class PlanechaseViewModel: ObservableObject {
    var contentManagerVM: ContentManagerViewModel
    var gameVM: GameViewModel
    @Published var isPlaying = false
    @Published var gradientId: Int
    @Published var zoomViewType: ZoomViewType
    @Published var useHellridePNG: Bool
    @Published var biggerCardsOnMap: Bool
    @Published var isPremium = false
    
    init() {
        gradientId = SaveManager.getOptions_GradientId()
        zoomViewType = SaveManager.getOptions_ZoomType()
        let optionToggles = SaveManager.getOptions_Toggles()
        biggerCardsOnMap = optionToggles.0
        useHellridePNG = optionToggles.1
        
        gameVM = GameViewModel()
        contentManagerVM = ContentManagerViewModel()
        contentManagerVM.planechaseVM = self
        isPremium = UserDefaults.standard.object(forKey: "IsPremium") as? Bool ?? false
    }
    
    func togglePlaying(classicGameMode: Bool = false) {
        withAnimation(.easeInOut(duration: 0.3)) {
            isPlaying.toggle()
        }
        
        if isPlaying {
            gameVM.startGame(withDeck: contentManagerVM.getDeck(), classicGameMode: classicGameMode)
        }
    }
    
    func setGradientId(_ gradient: Int) {
        withAnimation(.easeInOut(duration: 0.3)) {
            gradientId = gradient
        }
        SaveManager.saveOptions_GradientId(gradient)
    }
    
    func setZoomViewType(_ zoomType: ZoomViewType) {
        withAnimation(.easeInOut(duration: 0.3)) {
            zoomViewType = zoomType
        }
        SaveManager.saveOptions_ZoomType(zoomType)
    }
    
    func saveToggles() {
        SaveManager.saveOptions_Toggles(bigCard: biggerCardsOnMap, hellride: useHellridePNG)
    }
}

enum ZoomViewType: Codable {
    case one
    case two
    case four
}
