//
//  GameViewModel.swift
//  Planechase
//
//  Created by Loic D on 21/02/2023.
//

import Foundation

class GameViewModel: ObservableObject {
    
    var deck: [Card] = []
    @Published var map: [[Card?]]
    
    init() {
        map = [[Card?]](
            repeating: [Card?](repeating: nil, count: 5),
            count: 5
           )
    }
    
    func startGame(withDeck: [Card]) {
        guard withDeck.count > 20 else { return }
        deck = withDeck
        deck.shuffle()
        
        map = [[Card?]](
            repeating: [Card?](repeating: nil, count: 5),
            count: 5
           )
        
        let center = Coord(x: 2, y: 2)
        addCardAtCoord(card: deck.removeFirst(), center)
    }
    
    func addCardAtCoord(card: Card, _ coord: Coord) {
        guard coord.x >= 0 && coord.y >= 0 && coord.x < map[0].count && coord.y < map[0].count else { return }
        map[coord.x][coord.y] = card
    }
}

struct Coord {
    let x: Int
    let y: Int
}

