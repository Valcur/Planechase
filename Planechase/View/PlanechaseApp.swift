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
                            Image(systemName: "calendar")
                            Text(NSLocalizedString("tab_week", comment: "My week"))
                        }
                    ContentManagerView()
                        .environmentObject(planechaseVM.contentManagerVM)
                        .tabItem {
                            Image(systemName: "calendar")
                            Text(NSLocalizedString("tab_week", comment: "My week"))
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
    
    init() {
        contentManagerVM = ContentManagerViewModel()
        gameVM = GameViewModel()
    }
    
    func togglePlaying() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isPlaying.toggle()
        }
        
        if isPlaying {
            gameVM.startGame(withDeck: contentManagerVM.getDeck())
        }
    }
}
