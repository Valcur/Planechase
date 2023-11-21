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
    @Published var importedCardsToChangeType: [Card] = []
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
                    let cardIndex = self.cardCollection.firstIndex(where: { $0.id == card.id })
                    if let cardIndex = cardIndex {
                        // For older user, update so they don't have to delete/redownload all cards
                        if let cardSet = card.cardSets?.first {
                            if self.cardCollection[cardIndex].cardSets == nil {
                                self.cardCollection[cardIndex].cardSets = [cardSet]
                            } else {
                                self.cardCollection[cardIndex].cardSets!.removeAll(where: { $0 == cardSet })
                                self.cardCollection[cardIndex].cardSets!.append(cardSet)
                            }
                        }
                        self.cardCollection[cardIndex].cardType = card.cardType
                    } else {
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
    
    func switchCardType(_ card: Card) {
        withAnimation(.easeInOut(duration: 0.3)) {
            if let index = importedCardsToChangeType.firstIndex(where: { $0.id == card.id }) {
                importedCardsToChangeType.remove(at: index)
            } else {
                importedCardsToChangeType.append(card)
            }
        }
    }
    
    func applyCardTypesChanges() {
        print("\(importedCardsToChangeType.count)")
        for card in importedCardsToChangeType {
            if let index = cardCollection.firstIndex(where: { $0.id == card.id }) {
                print("changing type")
                var cardType = cardCollection[index].cardType
                if cardType == .plane {
                    cardType = .phenomenon
                } else {
                    cardType = .plane
                }
                cardCollection[index].cardType = cardType
                print(cardCollection[index].cardType)
            }
        }
        applyChangesToCollection(shouldSaveCustomImages: false)
        importedCardsToChangeType = []
    }
    
    func selectAll() {
        for card in filteredCardCollection {
            if selectedDeck.deckCardIds.firstIndex(where: { $0 == card.id }) == nil {
                decks[selectedDeckId].deckCardIds.append(card.id)
            }
        }
        
        updateSelectedCardsCountInCollection()
        updateCardCollectionVisualState()
        SaveManager.saveDecks(decks)
    }
    
    func unselectAll() {
        for card in filteredCardCollection {
            if let index = selectedDeck.deckCardIds.firstIndex(where: { $0 == card.id }) {
                decks[selectedDeckId].deckCardIds.remove(at: index)
            }
        }
        
        updateSelectedCardsCountInCollection()
        updateCardCollectionVisualState()
        SaveManager.saveDecks(decks)
    }
    
    private func updateCardCollectionVisualState() {
        for card in cardCollection {
            if selectedDeck.deckCardIds.contains(where: { $0 == card.id }) {
                card.state = .selected
            } else {
                card.state = .showed
            }
        }
    }
    
    func applyChangesToCollection(shouldSaveCustomImages: Bool = true) {
        updateSelectedCardsCountInCollection()
        saveCollection(shouldSaveCustomImages: shouldSaveCustomImages)
    }
    
    private func saveCollection(shouldSaveCustomImages: Bool = true) {
        SaveManager.saveCardArray(cardCollection, shouldSaveCustomImages: shouldSaveCustomImages)
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
    
    func removeAllOfficialCards() {
        cardCollection.removeAll(where: { $0.imageURL != nil })
        removeObsoleteCardIds()
        updateSelectedCardsCountInCollection()
        applyChangesToCollection()
    }
    
    func removeAllUnofficialCards() {
        for card in cardCollection {
            if card.imageURL == nil {
                removeCardFromCollection(card)
            }
        }
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
    
    func toggleCardTypeLineFilter(_ typeLine: CardTypeLine) {
        if collectionFilter.cardTypeLine == nil {
            collectionFilter.cardTypeLine = typeLine
        } else {
            if collectionFilter.cardTypeLine == typeLine {
                collectionFilter.cardTypeLine = nil
            } else {
                collectionFilter.cardTypeLine = typeLine
            }
        }
        updateFilteredCardCollection()
    }
    
    func updateFilteredCardCollection() {
        DispatchQueue.main.async { [self] in
            withAnimation(.easeInOut(duration: 0.3)) {
                self.filteredCardCollection = self.cardCollection
                
                if self.collectionFilter.cardType == .official {
                    self.filteredCardCollection = self.filteredCardCollection.filter({ $0.imageURL != nil })
                }
                if self.collectionFilter.cardType == .unofficial {
                    self.filteredCardCollection = self.filteredCardCollection.filter({ $0.imageURL == nil })
                }
                
                
                
                if self.collectionFilter.cardsInDeck == .present {
                    self.filteredCardCollection = self.filteredCardCollection.filter({ self.selectedDeck.deckCardIds.firstIndex(of: $0.id) != nil})
                }
                if self.collectionFilter.cardsInDeck == .absent {
                    self.filteredCardCollection = self.filteredCardCollection.filter({ self.selectedDeck.deckCardIds.firstIndex(of: $0.id) == nil})
                }
                if self.collectionFilter.cardsInDeck == .absentInAll {
                    for deck in self.decks {
                        self.filteredCardCollection = self.filteredCardCollection.filter({ deck.deckCardIds.firstIndex(of: $0.id) == nil})
                    }
                }

                if let cardSetFilter = collectionFilter.cardSet {
                    self.filteredCardCollection = self.filteredCardCollection.filter({ ($0.cardSets ?? []).contains(cardSetFilter) })
                }
                
                if let cardTypeFilter = collectionFilter.cardTypeLine {
                    if cardTypeFilter == .plane {
                        self.filteredCardCollection = self.filteredCardCollection.filter({ $0.cardType == .plane })
                    }
                    if cardTypeFilter == .phenomenon {
                        self.filteredCardCollection = self.filteredCardCollection.filter({ $0.cardType == .phenomenon })
                    }
                }
            }
        }
    }
}
