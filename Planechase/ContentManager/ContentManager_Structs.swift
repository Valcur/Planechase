//
//  ContentManager_Structs.swift
//  Planechase
//
//  Created by Loic D on 24/03/2023.
//

import Foundation

struct Deck: Codable {
    let deckId: Int
    var name: String
    var deckCardIds: [String]
}

struct Filter {
    var cardType: CollectionCardTypeFilter = .both
    var cardsInDeck: CollectionCardsInDeckFilter = .both
    var cardSet: CardSet?
    var cardTypeLine: CardTypeLine?
    
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

enum CardTypeLine: Codable {
    case plane
    case phenomenon
    
    static func typeForTypeLine(_ typleLine: String?) -> CardTypeLine? {
        guard let typeLine = typleLine else { return nil }
        if typeLine.contains("lane") {
            return .plane
        } else {
            return .phenomenon
        }
    }
}

enum CardSet: Codable {
    case planechasePlanes
    case planechaseAnthologyPlanes
    case planechase2012Planes
    case marchOfTheMachineCommander
    case drWho
    
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
        case .drWho:
            return "WHO"
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
            return "March of the Machine"
        case .drWho:
            return "Dr Who"
            
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
        case "WHO":
            return .drWho
        default:
            return .marchOfTheMachineCommander
        }
    }
    
    static func getAll() -> [CardSet] {
        return [.planechasePlanes, .planechaseAnthologyPlanes, .planechase2012Planes, .marchOfTheMachineCommander, .drWho]
    }
}
