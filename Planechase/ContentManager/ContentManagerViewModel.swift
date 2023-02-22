//
//  ContentManagerViewModel.swift
//  Planechase
//
//  Created by Loic D on 20/02/2023.
//

import Foundation

class ContentManagerViewModel: ObservableObject {
    
    @Published var cardCollection: [Card]
    @Published var selectedCardsInCollection: Int = 0
    
    init() {
        cardCollection = SaveManager.getSavedCardArray()
        selectedCardsInCollection = cardCollection.filter({ $0.state == .selected }).count
    }
    
    func downloadPlanechaseCardsFromScryfall() {
        DispatchQueue.main.async {
            self.addAllPlanechaseCardsFromScryfall()
        }
    }
    
    // Return all the cards the player want to play with
    func getSelectedCards() -> [Card] {
        return cardCollection
    }
    
    private func updateSelectedCardsCountInCollection() {
        selectedCardsInCollection = cardCollection.filter({ $0.state == .selected }).count
    }
    
    func addToCollection(_ cards: [Card]) {
        DispatchQueue.main.async {
            for card in cards {
                if !self.cardCollection.contains(where: { $0.id == card.id }) {
                    self.cardCollection.append(card)
                }
            }
            self.applyChangesToCollection()
        }
    }
    
    func applyChangesToCollection() {
        updateSelectedCardsCountInCollection()
        saveCollection()
    }
    
    private func saveCollection() {
        SaveManager.saveCardArray(cardCollection)
    }
    
    // Return all cards selected by the user
    func getDeck() -> [Card] {
        var selectedCards = cardCollection.filter({ $0.state == .selected })
        selectedCards = selectedCards.map({ $0.new() })
        print("User has \(selectedCards.count)/\(cardCollection.count) cards in his deck")
        return selectedCards
    }
}
