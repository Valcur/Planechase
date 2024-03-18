//
//  Card.swift
//  Planechase
//
//  Created by Loic D on 20/02/2023.
//

import SwiftUI

class Card: ObservableObject, Equatable {
    var id: String
    var image: UIImage?
    var imageURL: String?
    var state: CardState
    var cardSets: [CardSet]?
    var cardType: CardTypeLine?
    var cardLang: String
    
    init(id: String, image: UIImage? = nil, imageURL: String? = nil, state: CardState, cardSets: [CardSet]? = nil, cardType: CardTypeLine? = nil, cardLang: String = "en") {
        self.state = state
        self.image = image
        self.imageURL = imageURL
        self.id = id
        self.cardSets = cardSets
        self.cardType = cardType
        self.cardLang = cardLang
    }
    
    func cardAppears() {
        if image == nil {
            let dlManager = DownloadManager(card: self, shouldImageBeSaved: true)
            dlManager.startDownloading() { img in
                DispatchQueue.main.async {
                    self.image = img
                    self.objectWillChange.send()
                }
            }
        }
    }
    
    func new() -> Card {
        return Card(id: self.id, image: self.image, imageURL: self.imageURL, state: self.state, cardSets: self.cardSets, cardType: self.cardType, cardLang: self.cardLang)
    }
    
    static let hellride = Card(id: "HELLRIDE_UNDEFINED", image: UIImage(named: "NoCard"), imageURL: "HELLRIDE", state: .pickable)
    
    static func == (lhs: Card, rhs: Card) -> Bool {
        return lhs.id == rhs.id
    }
}

enum CardState: Int, Codable {
    case selected = 3
    case pickable = 2
    case showed = 0
    case hidden = 1
}
