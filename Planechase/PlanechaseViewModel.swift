//
//  PlanechaseViewModel.swift
//  Planechase
//
//  Created by Loic D on 12/12/2023.
//

import SwiftUI

class PlanechaseViewModel: ObservableObject {
    var contentManagerVM: ContentManagerViewModel
    var gameVM: GameViewModel
    
    @Published var isPlaying = false
    var lifeCounterProfiles: [PlayerCustomProfileInfo]
    @Published var showDiscordInvite = false
    @Published var paymentProcessing = false
    @Published var treacheryData: TreacheryData
    
    @Published var isPremium = false
    
    // Options
    @Published var gradientId: Int
    @Published var zoomViewType: ZoomViewType
    @Published var useHellridePNG: Bool
    @Published var biggerCardsOnMap: Bool
    @Published var noHammerRow: Bool
    @Published var noDice: Bool
    @Published var showCustomCardsTypeButtons: Bool
    @Published var showPlusMinus: Bool
    @Published var biggerLifeTotal: Bool
    @Published var fullscreenCommanderAndCounters: Bool
    @Published var diceOptions: DiceOptions
    @Published var lifeCounterOptions: LifeOptions
    @Published var useBlurredBackground = false
    @Published var treacheryOptions: TreacheryOptions
    
    init() {
        gradientId = SaveManager.getOptions_GradientId()
        zoomViewType = SaveManager.getOptions_ZoomType()
        
        let optionToggles = SaveManager.getOptions_Toggles()
        biggerCardsOnMap = optionToggles.0
        useHellridePNG = optionToggles.1
        noHammerRow = optionToggles.2
        noDice = optionToggles.3
        useBlurredBackground = optionToggles.4
        showCustomCardsTypeButtons = optionToggles.5
        
        let lifeOptionToggles = SaveManager.getOptions_LifeToggles()
        showPlusMinus = lifeOptionToggles.0
        biggerLifeTotal = lifeOptionToggles.1
        fullscreenCommanderAndCounters = lifeOptionToggles.2
        
        diceOptions = SaveManager.getOptions_DiceOptions()
        lifeCounterOptions = SaveManager.getOptions_LifeOptions()
        lifeCounterProfiles = SaveManager.getOptions_LifePlayerProfiles()
        treacheryOptions = SaveManager.getOptions_TreacheryOptions()
        treacheryData = TreacheryData()
        
        gameVM = GameViewModel()
        contentManagerVM = ContentManagerViewModel()
        contentManagerVM.planechaseVM = self
        isPremium = UserDefaults.standard.object(forKey: "IsPremium") as? Bool ?? false
        showDiscordInvite = UserDefaults.standard.object(forKey: "ShowDiscordInvite") as? Bool ?? true
        treacheryData.filter(getSelectedRarities())
    }
    
    func togglePlaying(classicGameMode: Bool = false) {
        withAnimation(.easeInOut(duration: 0.3)) {
            isPlaying.toggle()
        }
        
        if isPlaying {
            gameVM.startGame(withDeck: contentManagerVM.getPlanarDeck(), classicGameMode: classicGameMode)
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
    
    func saveTreacheryOptions() {
        SaveManager.saveOptions_TreacheryOptions(treacheryOptions)
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
        SaveManager.saveOptions_Toggles(bigCard: biggerCardsOnMap, hellride: useHellridePNG, noHammer: noHammerRow, noDice: noDice, blurredBackground: useBlurredBackground, showCustomCardsTypeButtons: showCustomCardsTypeButtons)
    }
    
    func saveLifeToggles() {
        SaveManager.saveOptions_LifeToggles(showPlusMinus: showPlusMinus, biggerLifeTotal: biggerLifeTotal, fullscreenCommanderAndCounters: fullscreenCommanderAndCounters)
    }
    
    func getSelectedRarities() -> [TreacheryData.Rarity] {
        var rarities = [TreacheryData.Rarity]()
        if treacheryOptions.isUsingUnco {
            rarities.append(.unco)
        }
        if treacheryOptions.isUsingRare {
            rarities.append(.rare)
        }
        if treacheryOptions.isUsingMythic {
            rarities.append(.mythic)
        }
        return rarities
    }
}

enum ZoomViewType: Codable {
    case one
    case two
    case two_cropped
    case four
}
