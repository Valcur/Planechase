//
//  GameViewModel.swift
//  Planechase
//
//  Created by Loic D on 21/02/2023.
//

import SwiftUI

class GameViewModel: ObservableObject {
    
    var deck: [Card] = []                       // The current cards pool to draw from
    var deckFull: [Card] = []                   // The whole card pool selected by the user
    @Published var map: [[Card?]]               // The eternities map board
    internal let center = Coord(x: 3, y: 3)      // The center coordinate of the map where should always be the selected plane
    @Published var travelModeEnable: Bool       // Has the user rolled a 6 and need to change plane
    @Published var cardToZoomIn: Card?          // nil if no card to zoom in, else show the card to fit the whole screen
    @Published var focusCenterToggler: Bool = false
    var isPlayingClassicMode: Bool = true
    @Published var otherCurrentPlanes: [Card] = []  // Other planes than the main one where the players are at the same time
    
    // Deck Controller
    @Published var showPlanarDeckController: Bool = false
    @Published var revealedCards: [Card] = []
    
    @Published var showLifePointsView: Bool = false
    
    init() {
        map = [[Card?]](
            repeating: [Card?](repeating: nil, count: 7),
            count: 7
           )
        cardToZoomIn = nil
        travelModeEnable = false
    }
    
    func startGame(withDeck: [Card], classicGameMode: Bool) {
        guard withDeck.count >= (classicGameMode ? 10 : 30) else { return }
        isPlayingClassicMode = classicGameMode
        otherCurrentPlanes = []
        deck = withDeck
        deckFull = withDeck.map({ $0.new() })
        deck.shuffle()
        
        if isPlayingClassicMode {
            startGame_Classic()
            return
        }
        
        map = [[Card?]](
            repeating: [Card?](repeating: nil, count: 7),
            count: 7
           )
        cardToZoomIn = nil
        travelModeEnable = false
        
        addCardAtCoord(card: drawCard(), center)
        setupNeighbors()
    }
    
    func addCardAtCoord(card: Card, _ coord: Coord) {
        guard isCoordinateInRange(coord: coord) else { return }
        map[coord.x][coord.y] = card
    }
    
    func toggleTravelMode() {
        if isPlayingClassicMode {
            toggleTravelMode_Classic()
            return
        }
        withAnimation(.easeInOut(duration: 0.3)) {
            travelModeEnable.toggle()
            cardToZoomIn = nil
        }
        if travelModeEnable {
            showHellride()
        } else {
            hideHellride()
        }
    }
    
    func showHellride() {
        let hellrideCoord = center.getNeighborCoordinates(getDiagnoal: true)
        
        for coord in hellrideCoord {
            if mapAt(coord) == nil {
                let card = Card.hellride.new()
                card.id = "HELLRIDE_\(coord.x)_\(coord.y)"
                addCardAtCoord(card: card, coord)
            }
        }
    }
    
    func hideHellride() {
        let hellrideCoord = center.getNeighborCoordinates(getDiagnoal: true)

        for coord in hellrideCoord {
            if mapAt(coord)?.imageURL == "HELLRIDE" {
                map[coord.x][coord.y] = nil
            }
        }
    }
    
    func travelTo(_ card: Card) {
        var coord = center
        for i in 0..<7 {
            for j in 0..<7 {
                let c = map[i][j]
                if c != nil && c?.id == card.id {
                    coord = Coord(x: i, y: j)
                }
            }
        }
        toggleTravelMode()

        let difference = Coord(x: coord.x - center.x, y: coord.y - center.y)
        print("Moving from \(coord.x) : \(coord.y) in direction \(difference.x) : \(difference.y)")
        
        // Move the map to make the place we want to travel the new center
        moveMap(direction: difference)
        
        // Draw new cards
        if  mapAt(center) == nil {
            addCardAtCoord(card: drawCard(), center)
        }
        
        map[center.x][center.y]?.state = .selected
        setupNeighbors()
        
        withAnimation(.easeInOut(duration: 0.5).delay(0.5)) {
            cardToZoomIn = getCenter()
        }
    }
    
    func getCenter() -> Card {
        return mapAt(center)!
    }
    
    func drawCard() -> Card {
        // Should only happened when the whole deck is on otherCurrentPlane
        if deck.count == 0 {
            if isPlayingClassicMode {
                return cardToZoomIn!
            } else {
                return getCenter()
            }
        }
        
        let card = deck.removeFirst()

        // If empty reshuffle deck with all cards not on the map
        if deck.count == 0 {
            deck = deckFull.map({ $0.new() })
            if !isPlayingClassicMode {
                for i in 0..<7 {
                    for j in 0..<7 {
                        let c = map[i][j]
                        if c != nil {
                            deck.removeAll(where: { $0.id == c!.id })
                        }
                    }
                }
            } else {
                deck.removeAll(where: { $0.id == cardToZoomIn!.id })
            }
            deck.removeAll(where: { $0.id == card.id })
            for otherCard in otherCurrentPlanes {
                deck.removeAll(where: { $0.id == otherCard.id })
            }
            deck.shuffle()
            print("New deck shuffled with \(deck.count) cards")
        }
        return card
    }
    
    private func mapAt(_ coord: Coord) -> Card? {
        guard isCoordinateInRange(coord: coord) else { return nil }
        return map[coord.x][coord.y]
    }
    
    private func setupNeighbors() {
        let centerNeighbors = center.getNeighborCoordinates()
        withAnimation(.easeInOut(duration: 0.5).delay(0.3)) {
            for coord in centerNeighbors {
                if mapAt(coord) == nil {
                    let card = drawCard()
                    card.state = .pickable
                    addCardAtCoord(card: card, coord)
                } else {
                    mapAt(coord)!.state = .pickable
                }
            }
        }
    }
    
    private func isCoordinateInRange(coord: Coord) -> Bool {
        return coord.x >= 0 && coord.y >= 0 && coord.x < map[0].count && coord.y < map[0].count
    }
    
    private func moveMap(direction: Coord) {
        var mapTmp = map
        for i in 0..<map.endIndex {
            for j in 0..<map.endIndex {
                let coord = Coord(x: i + direction.x, y: j + direction.y)
                if isCoordinateInRange(coord: coord) {
                    mapTmp[i][j] = map[coord.x][coord.y]
                    mapTmp[i][j]?.state = .showed
                } else {
                    mapTmp[i][j] = nil
                }
            }
        }
        
        withAnimation(.easeInOut(duration: 0.5)) {
            map = mapTmp
            removePlanesFarAway()
        }
    }
    
    // Remove planes 4 block in distance from the center
    private func removePlanesFarAway() {
        let farCoords = [
            Coord(x: 0, y: 0),
            Coord(x: 1, y: 0),
            Coord(x: 2, y: 0),
            Coord(x: 0, y: 1),
            Coord(x: 1, y: 1),
            Coord(x: 0, y: 2),
            
            Coord(x: 0, y: 6),
            Coord(x: 1, y: 6),
            Coord(x: 2, y: 6),
            Coord(x: 0, y: 5),
            Coord(x: 1, y: 5),
            Coord(x: 0, y: 4),
            
            Coord(x: 6, y: 0),
            Coord(x: 5, y: 0),
            Coord(x: 4, y: 0),
            Coord(x: 6, y: 1),
            Coord(x: 5, y: 1),
            Coord(x: 6, y: 2),
            
            Coord(x: 6, y: 6),
            Coord(x: 5, y: 6),
            Coord(x: 4, y: 6),
            Coord(x: 6, y: 5),
            Coord(x: 5, y: 5),
            Coord(x: 6, y: 4),
        ]
        
        for coord in farCoords {
            withAnimation(.none) {
                map[coord.x][coord.y] = nil
            }
        }
    }
}

// MARK: Classic game mode
extension GameViewModel {
    func toggleTravelMode_Classic() {
        withAnimation(.easeInOut(duration: 0.3)) {
            cardToZoomIn = drawCard()
        }
    }
    
    func startGame_Classic() {
        map = [[Card?]](
            repeating: [Card?](repeating: nil, count: 7),
            count: 7
           )
        cardToZoomIn = drawCard()
        travelModeEnable = false
    }
}

extension GameViewModel {
    func togglePlanarDeckController() {
        showPlanarDeckController.toggle()
        
        // Shuffle the remaining revealed card at the bottom in a random order
        if !showPlanarDeckController {
            revealedCards.shuffle()
            for card in revealedCards {
                deck.append(card)
            }
        }
        
        revealedCards = []
        self.objectWillChange.send()
    }
    
    func revealTopPlanarDeckCard() {
        guard deck.count >= 1 else { return }
        var deckWillBeShuffled = false
        
        if deck.count == 1 {
            deckWillBeShuffled = true
        }
        let card = drawCard()
        
        if deckWillBeShuffled {
            for card in revealedCards {
                deck.removeAll(where: { $0.id == card.id })
            }
        }
        
        revealedCards.append(card)
    }
    
    func putCardToBottom(_ card: Card) {
        deck.append(card)
        removeCardFromRevealed(card)
    }
    
    func putCardToTop(_ card: Card) {
        deck.insert(card, at: 0)
        removeCardFromRevealed(card)
    }
    
    func planeswalkTo(_ card: Card) {
        if isPlayingClassicMode {
            if deck.count == 0 {
                deck.append(cardToZoomIn!)
            }
            withAnimation(.easeInOut(duration: 0.3)) {
                cardToZoomIn = card
            }
        } else {
            if deck.count == 0 {
                deck.append(getCenter())
            }
            addCardAtCoord(card: card, center)
        }
        removeCardFromRevealed(card)
    }
    
    func stayAndPlaneswalkTo(_ card: Card) {
        otherCurrentPlanes.append(card)
        
        removeCardFromRevealed(card)
    }
    
    func switchToOtherCurrentPLane(_ card: Card) {
        if isPlayingClassicMode {
            otherCurrentPlanes.append(cardToZoomIn!)
            
            withAnimation(.easeInOut(duration: 0.3)) {
                cardToZoomIn = card
            }
        } else {
            let centerCard = getCenter()
            
            if cardToZoomIn?.id == centerCard.id {
                withAnimation(.easeInOut(duration: 0.3)) {
                    cardToZoomIn = card
                }
            }
            
            otherCurrentPlanes.append(centerCard)
            
            withAnimation(.easeInOut(duration: 0.3)) {
                addCardAtCoord(card: card, center)
            }
        }
        otherCurrentPlanes.removeAll(where: { $0.id == card.id })
    }
    
    private func removeCardFromRevealed(_ card: Card) {
        revealedCards.removeAll(where: { $0.id == card.id })
    }
}
