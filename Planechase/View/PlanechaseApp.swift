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
        UITabBar.appearance().barTintColor = .black
    }
    
    var body: some Scene {
        WindowGroup {
            if planechaseVM.isPlaying {
                GameView()
                    .environmentObject(planechaseVM)
                    .environmentObject(planechaseVM.gameVM)
            } else {
                TabView {
                    MainMenuView()
                        .environmentObject(planechaseVM)
                        .tabItem {
                            Image(systemName: "play.fill")
                            Text("Play")
                        }
                    ContentManagerView()
                        .environmentObject(planechaseVM)
                        .environmentObject(planechaseVM.contentManagerVM)
                        .tabItem {
                            Image(systemName: "list.dash")
                            Text("Collection")
                        }
                    OptionsMenuView()
                        .environmentObject(planechaseVM)
                        .tabItem {
                            Image(systemName: "gear")
                            Text("Options")
                        }
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
    
    init() {
        contentManagerVM = ContentManagerViewModel()
        gameVM = GameViewModel()
        gradientId = 1
    }
    
    func togglePlaying() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isPlaying.toggle()
        }
        
        if isPlaying {
            gameVM.startGame(withDeck: contentManagerVM.getDeck())
        }
    }
    
    func setGradientId(_ gradient: Int) {
        withAnimation(.easeInOut(duration: 0.3)) {
            gradientId = gradient
        }
    }
}
