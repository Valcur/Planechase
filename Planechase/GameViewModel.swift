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
    private let center = Coord(x: 3, y: 3)      // The center coordinate of the map where should always be the selected plane
    @Published var travelModeEnable: Bool       // Has the user rolled a 6 and need to change plane
    @Published var cardToZoomIn: Card?          // nil if no card to zoom in, else show the card to fit the whole screen
    @Published var focusCenterToggler: Bool = false
    
    init() {
        map = [[Card?]](
            repeating: [Card?](repeating: nil, count: 7),
            count: 7
           )
        cardToZoomIn = nil
        travelModeEnable = false
    }
    
    func startGame(withDeck: [Card]) {
        guard withDeck.count > 20 else { return }
        deck = withDeck
        deckFull = withDeck
        deck.shuffle()
        
        map = [[Card?]](
            repeating: [Card?](repeating: nil, count: 7),
            count: 7
           )
        cardToZoomIn = nil
        travelModeEnable = false
        
        addCardAtCoord(card: deck.removeFirst(), center)
        setupNeighbors()
    }
    
    func addCardAtCoord(card: Card, _ coord: Coord) {
        guard isCoordinateInRange(coord: coord) else { return }
        map[coord.x][coord.y] = card
    }
    
    func toggleTravelMode() {
        withAnimation(.easeInOut(duration: 0.3)) {
            travelModeEnable.toggle()
            cardToZoomIn = nil
        }
    }
    
    func travelTo(_ coord: Coord) {
        toggleTravelMode()
        let difference = Coord(x: coord.x - center.x, y: coord.y - center.y)
        print("Moving from \(coord.x) : \(coord.y) in direction \(difference.x) : \(difference.y)")
        
        // Move the map to make the place we want to travel the new center
        moveMap(direction: difference)
        
        // Draw new cards
        map[center.x][center.y]?.state = .selected
        setupNeighbors()
        
        withAnimation(.easeInOut(duration: 0.5).delay(0.3)) {
            cardToZoomIn = map[center.x][center.y]!
        }
    }
    
    func getCenter() -> Card {
        return mapAt(center)!
    }
    
    private func mapAt(_ coord: Coord) -> Card? {
        guard isCoordinateInRange(coord: coord) else { return nil }
        return map[coord.x][coord.y]
    }
    
    private func setupNeighbors() {
        let centerNeighbors = center.getNeighborCoordinates()
        
        for coord in centerNeighbors {
            if mapAt(coord) == nil {
                let card = deck.removeFirst()
                card.state = .pickable
                addCardAtCoord(card: card, coord)
            } else {
                mapAt(coord)!.state = .pickable
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
            map[coord.x][coord.y] = nil
        }
    }
}
