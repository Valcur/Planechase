//
//  SaveManager.swift
//  Planechase
//
//  Created by Loic D on 20/02/2023.
//

import SwiftUI

class SaveManager {
    static func saveCardArray(_ cards: [Card], shouldSaveCustomImages: Bool = true) {
        // Save id, url and image if its a custom card
        var cardsToSave: [SavedCardData] = []
        var customCardsToSave: [SavedCardData] = []
        for card in cards {
            // Custom card imported
            if card.imageURL == nil {
                if shouldSaveCustomImages {
                    SaveManager.saveCustomImageFromCard(card)
                }
                customCardsToSave.append(SavedCardData(
                    id: card.id,
                    isCustomImage: true,
                    imageURL: card.imageURL,
                    state: card.state,
                    cardSets: card.cardSets,
                    cardType: card.cardType
                ))
            }
            // Card from scryfall
            else {
                cardsToSave.append(SavedCardData(
                    id: card.id,
                    isCustomImage: false,
                    imageURL: card.imageURL,
                    state: card.state,
                    cardSets: card.cardSets,
                    cardType: card.cardType
                ))
            }
        }
        
        if let encoded = try? JSONEncoder().encode(cardsToSave) {
            UserDefaults.standard.set(encoded, forKey: "CardsCollection")
        }

        if let customEncoded = try? JSONEncoder().encode(customCardsToSave) {
            UserDefaults.standard.set(customEncoded, forKey: "CustomCardsCollection")
        }
    }
    
    static func getSavedCardArray() -> [Card] {
        var cards: [Card] = []

        if let data = UserDefaults.standard.object(forKey: "CustomCardsCollection") as? Data,
           let cardsSaved = try? JSONDecoder().decode([SavedCardData].self, from: data) {
            
            for card in cardsSaved {
                // Custom card imported
                if card.isCustomImage {
                    if let image = getCustomImageFromCard(card) {
                        cards.append(Card(id: card.id,
                                          image: image,
                                          imageURL: nil,
                                          state: card.state,
                                          cardSets: card.cardSets,
                                          cardType: card.cardType
                                         ))
                    }
                }
            }
        }
        
        // Leaving custom card support so it still work for older users
        if let data = UserDefaults.standard.object(forKey: "CardsCollection") as? Data,
           let cardsSaved = try? JSONDecoder().decode([SavedCardData].self, from: data) {
            
            for card in cardsSaved {
                // Custom card imported
                if card.isCustomImage {
                    if let image = getCustomImageFromCard(card) {
                        cards.append(Card(id: card.id,
                                          image: image,
                                          imageURL: nil,
                                          state: card.state,
                                          cardSets: card.cardSets,
                                          cardType: card.cardType
                                         ))
                    }
                }
                // Card from scryfall
                else {
                    cards.append(Card(id: card.id,
                                      image: nil,
                                      imageURL: card.imageURL,
                                      state: card.state,
                                      cardSets: card.cardSets,
                                      cardType: card.cardType
                                     ))
                }
            }
        }

        return cards
    }
    
    static func saveCustomImageFromCard(_ card: Card) {
        guard let image = card.image else { return }
        guard let data = image.jpegData(compressionQuality: 0.5) else { return }
        let encoded = try! PropertyListEncoder().encode(data)
        UserDefaults.standard.set(encoded, forKey: "ImportedImage_\(card.id)")
    }
    
    static func getCustomImageFromCard(_ card: SavedCardData) -> UIImage? {
        guard let data = UserDefaults.standard.data(forKey: "ImportedImage_\(card.id)") else { return nil }
        let decoded = try! PropertyListDecoder().decode(Data.self, from: data)
        
        guard let inputImage = UIImage(data: decoded) else {
            return nil
        }
        
        return inputImage
    }
    
    static func deleteCustomImageFromCard(_ card: Card) {
        UserDefaults.standard.removeObject(forKey: "ImportedImage_\(card.id)")
    }
    
    static func saveDecks(_ decks: [Deck]) {
        if let encoded = try? JSONEncoder().encode(decks) {
            UserDefaults.standard.set(encoded, forKey: "Decks")
        }
    }
    
    static func getDecks() -> [Deck] {
        if let data = UserDefaults.standard.object(forKey: "Decks") as? Data,
           let decks = try? JSONDecoder().decode([Deck].self, from: data) {
            return decks
        }
        var noDecks: [Deck] = []
        for i in 0..<10 {
            noDecks.append(Deck(deckId: i, name: "Deck \(i + 1)", deckCardIds: []))
        }
        return noDecks
    }
    
    static func getSelectedDeckId() -> Int {
        return UserDefaults.standard.object(forKey: "SelectedDeckId") as? Int ?? 0
    }
    
    static func saveSelectedDeckId(deckId: Int) {
        UserDefaults.standard.set(deckId, forKey: "SelectedDeckId")
    }
    
    struct SavedCardData: Codable {
        var id: String
        var isCustomImage: Bool
        var imageURL: String?
        var state: CardState
        var cardSets: [CardSet]?
        var cardType: CardTypeLine?
    }
}

// Options
extension SaveManager {
    static func saveOptions_ZoomType(_ zoomViewType: ZoomViewType) {
        if let encoded = try? JSONEncoder().encode(zoomViewType) {
            UserDefaults.standard.set(encoded, forKey: "ZoomViewType")
        }
    }
    
    static func getOptions_ZoomType() -> ZoomViewType {
        if let data = UserDefaults.standard.object(forKey: "ZoomViewType") as? Data,
           let zoom = try? JSONDecoder().decode(ZoomViewType.self, from: data) {
            return zoom
        }
        return UIDevice.isIPad ? .two : .one
    }
    
    static func saveOptions_DiceOptions(_ diceOptions: DiceOptions) {
        if let encoded = try? JSONEncoder().encode(diceOptions) {
            UserDefaults.standard.set(encoded, forKey: "DiceOptions")
        }
    }
    
    static func getOptions_DiceOptions() -> DiceOptions {
        if let data = UserDefaults.standard.object(forKey: "DiceOptions") as? Data,
           let diceOptions = try? JSONDecoder().decode(DiceOptions.self, from: data) {
            return diceOptions
        }
        return DiceOptions(diceStyle: 0, diceColor: 0, numberOfFace: 6, useChoiceDiceFace: false)
    }
    
    static func saveOptions_LifeOptions(_ lifeOptions: LifeOptions) {
        if let encoded = try? JSONEncoder().encode(lifeOptions) {
            UserDefaults.standard.set(encoded, forKey: "LifeOptions")
        }
    }
    
    static func getOptions_LifeOptions() -> LifeOptions {
        if let data = UserDefaults.standard.object(forKey: "LifeOptions") as? Data,
           let lifeOptions = try? JSONDecoder().decode(LifeOptions.self, from: data) {
            return lifeOptions
        }
        return LifeOptions(useLifeCounter: true, useCommanderDamages: true, colorPaletteId: 0, nbrOfPlayers: 4, startingLife: 40, backgroundStyleId: -1, autoHideLifepointsCooldown: 15,  useMonarchToken: true, monarchTokenStyleId: -1)
    }
    
    static func saveOptions_TreacheryOptions(_ treacheryOptions: TreacheryOptions) {
        if let encoded = try? JSONEncoder().encode(treacheryOptions) {
            UserDefaults.standard.set(encoded, forKey: "TreacheryOptions")
        }
    }
    
    static func getOptions_TreacheryOptions() -> TreacheryOptions {
        if let data = UserDefaults.standard.object(forKey: "TreacheryOptions") as? Data,
           let treacheryOptions = try? JSONDecoder().decode(TreacheryOptions.self, from: data) {
            return treacheryOptions
        }
        return TreacheryOptions(isTreacheryEnabled: false, isUsingUnco: true, isUsingRare: false, isUsingMythic: false)
    }
    
    static func saveOptions_LifePlayerProfiles(_ profiles: [PlayerCustomProfileInfo]) {
        var profilesData = [PlayerCustomProfile]()
        for profile in profiles {
            profilesData.append(PlayerCustomProfile(profile: profile))
        }

        print(profilesData)
        if let encoded = try? JSONEncoder().encode(profilesData) {
            UserDefaults.standard.set(encoded, forKey: "LifePlayerProfilesOptions")
        }
    }
    
    static func saveOptions_LifePlayerProfiles_CustomImage(_ profiles: [PlayerCustomProfileInfo], i: Int) {
        let profile = profiles[i]
        if let data = profile.customImage?.pngData() {
            let encoded = try! PropertyListEncoder().encode(data)
            UserDefaults.standard.set(encoded, forKey: "ProfileImage_\(profile.id)")
        }
    }
    
    static func deleteOptions_LifePlayerProfile_CustomImage(profile: PlayerCustomProfileInfo) {
        UserDefaults.standard.removeObject(forKey: "ProfileImage_\(profile.id)")
    }
    
    static func getOptions_LifePlayerProfiles() -> [PlayerCustomProfileInfo] {
        if let data = UserDefaults.standard.object(forKey: "LifePlayerProfilesOptions") as? Data,
            var profilesData = try? JSONDecoder().decode([PlayerCustomProfile].self, from: data) {
            var profiles = [PlayerCustomProfileInfo]()
            for i in 0..<profilesData.count {
                // Get images
                if let data = UserDefaults.standard.data(forKey: "ProfileImage_\(profilesData[i].id)") {
                    let decoded = try! PropertyListDecoder().decode(Data.self, from: data)
                    profilesData[i].customImageData = decoded
                }
                profiles.append(PlayerCustomProfileInfo(profileData: profilesData[i]))
            }
            return profiles
        }
        return []
    }
    
    static func saveLastUsedSetup(_ setup: LastUsedSetup) {
        if let encoded = try? JSONEncoder().encode(setup) {
            UserDefaults.standard.set(encoded, forKey: "LastUsedSetup")
            print("Saving setup")
        }
    }
    
    static func getLastUsedSetup() -> LastUsedSetup {
        if let data = UserDefaults.standard.object(forKey: "LastUsedSetup") as? Data,
           let setup = try? JSONDecoder().decode(LastUsedSetup.self, from: data) {
            return setup
        }
        return LastUsedSetup.getDefaultSetup()
    }
    
    static func saveOptions_GradientId(_ gradientId: Int) {
        UserDefaults.standard.set(gradientId, forKey: "GradientId")
    }
    
    static func getOptions_GradientId() -> Int {
        return UserDefaults.standard.object(forKey: "GradientId") as? Int ?? 1
    }
    
    static func saveOptions_Toggles(bigCard: Bool, hellride: Bool, noHammer: Bool, noDice: Bool, blurredBackground: Bool, showCustomCardsTypeButtons: Bool) {
        UserDefaults.standard.set(bigCard, forKey: "BiggerCardsOnMap")
        UserDefaults.standard.set(hellride, forKey: "UseHellridePNG")
        UserDefaults.standard.set(noHammer, forKey: "NoHammer")
        UserDefaults.standard.set(noDice, forKey: "NoDice")
        UserDefaults.standard.set(blurredBackground, forKey: "BlurredBackground")
        UserDefaults.standard.set(showCustomCardsTypeButtons, forKey: "ShowCustomCardsTypeButtons")
    }
    
    static func getOptions_Toggles() -> (Bool, Bool, Bool, Bool, Bool, Bool) {
        let bigCards = UserDefaults.standard.object(forKey: "BiggerCardsOnMap") as? Bool ?? false
        let hellRide = UserDefaults.standard.object(forKey: "UseHellridePNG") as? Bool ?? false
        let noHammer = UserDefaults.standard.object(forKey: "NoHammer") as? Bool ?? true
        let noDice = UserDefaults.standard.object(forKey: "NoDice") as? Bool ?? false
        let blurredBackground = UserDefaults.standard.object(forKey: "BlurredBackground") as? Bool ?? false
        let showCustomCardsTypeButtons = UserDefaults.standard.object(forKey: "ShowCustomCardsTypeButtons") as? Bool ?? true
        return (bigCards, hellRide, noHammer, noDice, blurredBackground, showCustomCardsTypeButtons)
    }
    
    static func saveOptions_LifeToggles(showPlusMinus: Bool, biggerLifeTotal: Bool, fullscreenCommanderAndCounters: Bool) {
        UserDefaults.standard.set(showPlusMinus, forKey: "ShowPlusMinus")
        UserDefaults.standard.set(biggerLifeTotal, forKey: "BiggerLifeTotal")
        UserDefaults.standard.set(fullscreenCommanderAndCounters, forKey: "FullscreenCommanderAndCounters")
    }
    
    static func getOptions_LifeToggles() -> (Bool, Bool, Bool) {
        let showPlusMinus = UserDefaults.standard.object(forKey: "ShowPlusMinus") as? Bool ?? true
        let biggerLifeTotal = UserDefaults.standard.object(forKey: "BiggerLifeTotal") as? Bool ?? false
        let fullscreenCommanderAndCounters = UserDefaults.standard.object(forKey: "FullscreenCommanderAndCounters") as? Bool ?? UIDevice.isIPhone
        return (showPlusMinus, biggerLifeTotal, fullscreenCommanderAndCounters)

    }
}
