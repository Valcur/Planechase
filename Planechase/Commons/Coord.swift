//
//  Coord.swift
//  Planechase
//
//  Created by Loic D on 21/02/2023.
//

import Foundation

struct Coord {
    let x: Int
    let y: Int
    
    func getNeighborCoordinates(getDiagnoal: Bool = false) -> [Coord] {
        if getDiagnoal {
            return [Coord(x: self.x + 1, y: self.y + 1),
                    Coord(x: self.x - 1, y: self.y - 1),
                    Coord(x: self.x - 1, y: self.y + 1),
                    Coord(x: self.x + 1, y: self.y - 1)]
        }
        return [Coord(x: self.x + 1, y: self.y),
                Coord(x: self.x - 1, y: self.y),
                Coord(x: self.x, y: self.y + 1),
                Coord(x: self.x, y: self.y - 1)]
    }
}
