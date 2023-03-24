//
//  ContentManager_Structs.swift
//  Planechase
//
//  Created by Loic D on 24/03/2023.
//

import Foundation

struct Deck: Codable {
    let deckId: Int
    let name: String
    var deckCardIds: [String]
}

struct Filter {
    var cardType: CollectionCardTypeFilter = .both
    var cardsInDeck: CollectionCardsInDeckFilter = .both
    
    enum CollectionCardTypeFilter {
        case official
        case unofficial
        case both
        
        mutating func toggle(value: CollectionCardTypeFilter) {
            if self == value {
                self = .both
            } else {
                self = value
            }
        }
    }
    
    enum CollectionCardsInDeckFilter {
        case present
        case absent
        case absentInAll
        case both
        
        mutating func toggle(value: CollectionCardsInDeckFilter) {
            if self == value {
                self = .both
            } else {
                self = value
            }
        }
    }
}
