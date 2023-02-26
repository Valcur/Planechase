//
//  ContentManagerViewModel.swift
//  Planechase
//
//  Created by Loic D on 20/02/2023.
//

import SwiftUI

class ContentManagerViewModel: ObservableObject {
    weak var planechaseVM: PlanechaseViewModel?
    @Published var cardCollection: [Card]
    @Published var decks: [Deck]
    @Published var selectedCardsInCollection: Int = 0
    @Published var selectedDeckId: Int
    var selectedDeck: Deck {
        return decks[selectedDeckId]
    }
    
    init() {
        cardCollection = SaveManager.getSavedCardArray()
        decks = SaveManager.getDecks()
        selectedDeckId = SaveManager.getSelectedDeckId()
        changeSelectedDeck(newDeckId: selectedDeckId)
    }
    
    func changeSelectedDeck(newDeckId: Int) {
        selectedDeckId = newDeckId
        print("Switching to \(selectedDeck.name)")
        // Update visual state of card collection
        for card in cardCollection {
            card.state = .showed
        }
        
        for cardId in selectedDeck.deckCardIds {
            if let index = cardCollection.firstIndex(where: { $0.id == cardId }) {
                cardCollection[index].state = .selected
            }
        }
        
        SaveManager.saveSelectedDeckId(deckId: selectedDeckId)
        updateSelectedCardsCountInCollection()
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
        selectedCardsInCollection = selectedDeck.deckCardIds.count
        planechaseVM?.objectWillChange.send()
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
    
    func addToDeck(_ card: Card) {
        decks[selectedDeckId].deckCardIds.append(card.id)
        updateSelectedCardsCountInCollection()
        SaveManager.saveDecks(decks)
    }
    
    func removeFromDeck(_ card: Card) {
        decks[selectedDeckId].deckCardIds.removeAll(where: { $0 == card.id })
        updateSelectedCardsCountInCollection()
        SaveManager.saveDecks(decks)
    }
    
    func selectAll() {
        decks[selectedDeckId].deckCardIds = []
        for card in cardCollection {
            decks[selectedDeckId].deckCardIds.append(card.id)
        }
        updateSelectedCardsCountInCollection()
        SaveManager.saveDecks(decks)
        for card in cardCollection {
            card.state = .selected
        }
    }
    
    func unselectAll() {
        decks[selectedDeckId].deckCardIds = []
        updateSelectedCardsCountInCollection()
        SaveManager.saveDecks(decks)
        for card in cardCollection {
            card.state = .showed
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
        return selectedCards
    }
    
    func removeCardFromCollection(_ card: Card) {
        cardCollection.removeAll(where: { $0.id == card.id })
        if card.imageURL == nil {
            SaveManager.deleteCustomImageFromCard(card)
        }
        applyChangesToCollection()
    }
    
    func importNewImageToCollection(image: UIImage) {
        let newCard = Card(id: createIdForNewImportedCard(), image: image, state: .showed)
        addToCollection([newCard])
    }
    
    private func createIdForNewImportedCard() -> String {
        var id = 1
        while cardCollection.contains(where: { $0.id == "\(id)" }) {
            id += 1
        }
        print("nid for new card : \(id)")
        return "\(id)"
    }
}

struct Deck: Codable {
    let deckId: Int
    let name: String
    var deckCardIds: [String]
}
