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
            // let isCustom SAVE IMAGE IF CUSTOM
            cardsToSave.append(SavedCardData(
                id: card.id,
                isCustomImage: card.imageURL == nil,
                imageURL: card.imageURL,
                state: card.state
            ))
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
                // let image = GET IMAGE BACK FOR CUSTOM
                cards.append(Card(id: card.id,
                                  image: nil,
                                  imageURL: card.imageURL,
                                  state: card.state
                                 ))
            }
        }

        return cards
    }
    
    func saveCustomSleeveArt(image: UIImage) {
        guard let data = image.jpegData(compressionQuality: 0.5) else { return }
        let encoded = try! PropertyListEncoder().encode(data)
        UserDefaults.standard.set(encoded, forKey: "CustomSleeveArtImage")
    }
    
    struct SavedCardData: Codable {
        var id: String
        var isCustomImage: Bool
        var imageURL: String?
        var state: CardState
    }
}
