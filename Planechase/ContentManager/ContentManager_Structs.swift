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
    var cardSet: CardSet?
    
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

enum CardSet: Codable {
    case planechasePlanes
    case planechaseAnthologyPlanes
    case planechase2012Planes
    case marchOfTheMachineCommander
    
    func setCode() -> String {
        switch self {
        case .planechasePlanes:
            return "OHOP"
        case .planechaseAnthologyPlanes:
            return "OPCA"
        case .planechase2012Planes:
            return "OPC2"
        case .marchOfTheMachineCommander:
            return "MOC"
        }
    }
    
    func setName() -> String {
        switch self {
        case .planechasePlanes:
            return "Planechase Planes"
        case .planechaseAnthologyPlanes:
            return "Planechase Anthology Planes"
        case .planechase2012Planes:
            return "Planechase 2012 Planes"
        case .marchOfTheMachineCommander:
            return "March of the Machine Commander"
        }
    }
    
    static func cardSetForCode(_ code: String) -> CardSet {
        switch code {
        case "OHOP":
            return .planechasePlanes
        case "OPCA":
            return .planechaseAnthologyPlanes
        case "OPC2":
            return .planechase2012Planes
        case "MOC":
            return .marchOfTheMachineCommander
        default:
            return .marchOfTheMachineCommander
        }
    }
    
    static func getAll() -> [CardSet] {
        return [.planechasePlanes, .planechaseAnthologyPlanes, .planechase2012Planes, .marchOfTheMachineCommander]
    }
}
