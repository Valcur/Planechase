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
    
    func getNeighborCoordinates(allowDiagnoal: Bool = false) -> [Coord] {
        var neighbors = [Coord(x: self.x + 1, y: self.y),
                         Coord(x: self.x - 1, y: self.y),
                         Coord(x: self.x, y: self.y + 1),
                         Coord(x: self.x, y: self.y - 1)]
        if allowDiagnoal {
            neighbors.append(Coord(x: self.x + 1, y: self.y + 1))
            neighbors.append(Coord(x: self.x - 1, y: self.y - 1))
            neighbors.append(Coord(x: self.x + 1, y: self.y - 1))
            neighbors.append(Coord(x: self.x - 1, y: self.y + 1))
        }
        return neighbors
    }
}
