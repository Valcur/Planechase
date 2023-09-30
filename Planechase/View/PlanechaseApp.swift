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
                GameView(lifeCounterOptions: planechaseVM.lifeCounterOptions, profiles: planechaseVM.lifeCounterProfiles)
                    .statusBar(hidden: true)
                    .environmentObject(planechaseVM)
                    .environmentObject(planechaseVM.gameVM)
                    .ignoresSafeArea(edges: [.top, .bottom])
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
                }
                .onAppear() {
                    // Not working from init
                    IAPManager.shared.startWith(arrayOfIds: [IAPManager.getSubscriptionId(), IAPManager.getLifetimeId()], sharedSecret: IAPManager.getSharedSecret())
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
    @Published var noHammerRow: Bool
    @Published var noDice: Bool
    @Published var diceOptions: DiceOptions
    @Published var lifeCounterOptions: LifeOptions
    var lifeCounterProfiles: [PlayerCustomProfile]
    @Published var isPremium = false
    @Published var showDiscordInvite = false
    @Published var paymentProcessing = false
    
    init() {
        gradientId = SaveManager.getOptions_GradientId()
        zoomViewType = SaveManager.getOptions_ZoomType()
        let optionToggles = SaveManager.getOptions_Toggles()
        biggerCardsOnMap = optionToggles.0
        useHellridePNG = optionToggles.1
        noHammerRow = optionToggles.2
        noDice = optionToggles.3
        diceOptions = SaveManager.getOptions_DiceOptions()
        lifeCounterOptions = SaveManager.getOptions_LifeOptions()
        lifeCounterProfiles = SaveManager.getOptions_LifePlayerProfiles()
        
        gameVM = GameViewModel()
        contentManagerVM = ContentManagerViewModel()
        contentManagerVM.planechaseVM = self
        isPremium = UserDefaults.standard.object(forKey: "IsPremium") as? Bool ?? false
        showDiscordInvite = UserDefaults.standard.object(forKey: "ShowDiscordInvite") as? Bool ?? true
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
    
    func setDiceOptions(_ dice: DiceOptions) {
        withAnimation(.easeInOut(duration: 0.3)) {
            diceOptions = dice
        }
        SaveManager.saveOptions_DiceOptions(diceOptions)
    }
    
    func setLifeOptions(_ life: LifeOptions) {
        withAnimation(.easeInOut(duration: 0.3)) {
            lifeCounterOptions = life
        }
        SaveManager.saveOptions_LifeOptions(life)
    }
    
    func saveProfiles_Info() {
        SaveManager.saveOptions_LifePlayerProfiles(lifeCounterProfiles)
    }
    
    func saveProfiles_Image(index: Int) {
        SaveManager.saveOptions_LifePlayerProfiles_CustomImage(lifeCounterProfiles, i: index)
    }
    
    func setZoomViewType(_ zoomType: ZoomViewType) {
        withAnimation(.easeInOut(duration: 0.3)) {
            zoomViewType = zoomType
        }
        SaveManager.saveOptions_ZoomType(zoomType)
    }
    
    func saveToggles() {
        SaveManager.saveOptions_Toggles(bigCard: biggerCardsOnMap, hellride: useHellridePNG, noHammer: noHammerRow, noDice: noDice)
    }
}

enum ZoomViewType: Codable {
    case one
    case two
    case two_cropped
    case four
}

struct LifeOptions: Codable {
    var useLifeCounter: Bool
    var useCommanderDamages: Bool
    var colorPaletteId: Int
    var nbrOfPlayers: Int
    var startingLife: Int
    
    // custom background
}
