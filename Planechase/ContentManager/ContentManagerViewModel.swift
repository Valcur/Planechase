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
    @Published var filteredCardCollection: [Card] = []
    @Published var decks: [Deck]
    @Published var selectedCardsInCollection: Int = 0
    @Published var selectedDeckId: Int
    @Published var collectionFilter: Filter = Filter()
    var selectedDeck: Deck {
        return decks[selectedDeckId]
    }
    
    init() {
        cardCollection = SaveManager.getSavedCardArray()
        decks = SaveManager.getDecks()
        selectedDeckId = SaveManager.getSelectedDeckId()
        changeSelectedDeck(newDeckId: selectedDeckId)
        updateFilteredCardCollection()
    }
    
    func changeSelectedDeck(newDeckId: Int) {
        selectedDeckId = newDeckId
        print("Switching to \(selectedDeck.name)")
        // Update visual state of card collection
        for card in cardCollection {
            card.state = .showed
        }
        
        removeObsoleteCardIds()
        
        SaveManager.saveSelectedDeckId(deckId: selectedDeckId)
        updateSelectedCardsCountInCollection()
    }
    
    func removeObsoleteCardIds() {
        var obsoleteCardIds: [String] = []
        for cardId in selectedDeck.deckCardIds {
            if let index = cardCollection.firstIndex(where: { $0.id == cardId }) {
                cardCollection[index].state = .selected
            } else {
                // The card no longer exist in the collection
                obsoleteCardIds.append(cardId)
            }
        }
        for cardId in obsoleteCardIds {
            decks[selectedDeckId].deckCardIds.removeAll(where: { $0 == cardId })
        }
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
        updateFilteredCardCollection()
        planechaseVM?.objectWillChange.send()
    }
    
    func addToCollection(_ cards: [Card]) {
        DispatchQueue.main.async {
            withAnimation(.easeInOut(duration: 0.3)) {
                for card in cards {
                    if !self.cardCollection.contains(where: { $0.id == card.id }) {
                        if card.imageURL != nil {
                            self.cardCollection.append(card)
                        } else {
                            self.cardCollection.insert(card, at: 0)
                        }
                    }
                }
                self.applyChangesToCollection()
            }
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
        removeObsoleteCardIds()
        updateSelectedCardsCountInCollection()
        applyChangesToCollection()
    }
    
    func importNewImageToCollection(image: UIImage) {
        let newCard = Card(id: createIdForNewImportedCard(), image: image, state: .showed)
        addToCollection([newCard])
    }
    
    private func createIdForNewImportedCard() -> String {
        let beforeId = "000000000000_"
        var id = 1
        while cardCollection.contains(where: { $0.id == "\(beforeId)\(id)" }) {
            id += 1
        }
        print("id for new card : \(beforeId)\(id)")
        return "\(beforeId)\(id)"
    }
    
    func updateFilteredCardCollection() {
        filteredCardCollection = cardCollection
        
        if collectionFilter.cardType == .official {
            filteredCardCollection = filteredCardCollection.filter({ $0.imageURL != nil })
        }
        if collectionFilter.cardType == .unofficial {
            filteredCardCollection = filteredCardCollection.filter({ $0.imageURL == nil })
        }
        
        if collectionFilter.cardsInDeck == .present {
            filteredCardCollection = filteredCardCollection.filter({ selectedDeck.deckCardIds.firstIndex(of: $0.id) != nil})
        }
        if collectionFilter.cardsInDeck == .absent {
            filteredCardCollection = filteredCardCollection.filter({ selectedDeck.deckCardIds.firstIndex(of: $0.id) == nil})
        }
        if collectionFilter.cardsInDeck == .absentInAll {
            for deck in decks {
                filteredCardCollection = filteredCardCollection.filter({ deck.deckCardIds.firstIndex(of: $0.id) == nil})
            }
        }
    }
}
