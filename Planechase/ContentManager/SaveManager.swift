//
//  SaveManager.swift
//  Planechase
//
//  Created by Loic D on 20/02/2023.
//

import SwiftUI

class SaveManager {
    static func saveCardArray(_ cards: [Card]) {
        // Save id, url and image if its a custom card
        var cardsToSave: [SavedCardData] = []
        for card in cards {
            // Custom card imported
            if card.imageURL == nil {
                SaveManager.saveCustomImageFromCard(card)
                cardsToSave.append(SavedCardData(
                    id: card.id,
                    isCustomImage: true,
                    imageURL: card.imageURL,
                    state: card.state
                ))
            }
            // Card from scryfall
            else {
                cardsToSave.append(SavedCardData(
                    id: card.id,
                    isCustomImage: false,
                    imageURL: card.imageURL,
                    state: card.state
                ))
            }
        }
        if let encoded = try? JSONEncoder().encode(cardsToSave) {
            UserDefaults.standard.set(encoded, forKey: "CardsCollection")
        }
        
    }
    
    static func getSavedCardArray() -> [Card] {
        var cards: [Card] = []

        if let data = UserDefaults.standard.object(forKey: "CardsCollection") as? Data,
           let cardsSaved = try? JSONDecoder().decode([SavedCardData].self, from: data) {
            
            for card in cardsSaved {
                // Custom card imported
                if card.isCustomImage {
                    if let image = getCustomImageFromCard(card) {
                        cards.append(Card(id: card.id,
                                          image: image,
                                          imageURL: nil,
                                          state: card.state
                                         ))
                    }
                }
                // Card from scryfall
                else {
                    cards.append(Card(id: card.id,
                                      image: nil,
                                      imageURL: card.imageURL,
                                      state: card.state
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
    
    struct SavedCardData: Codable {
        var id: String
        var isCustomImage: Bool
        var imageURL: String?
        var state: CardState
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
        return .two
    }
    
    static func saveOptions_GradientId(_ gradientId: Int) {
        UserDefaults.standard.set(gradientId, forKey: "GradientId")
    }
    
    static func getOptions_GradientId() -> Int {
        return UserDefaults.standard.object(forKey: "GradientId") as? Int ?? 1
    }
}
