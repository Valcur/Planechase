//
//  LifePointsViewModel.swift
//  Planechase
//
//  Created by Loic D on 28/10/2023.
//

import SwiftUI

class LifePointsViewModel: ObservableObject {
    @Published var numberOfPlayer: Int
    @Published var players: [PlayerProfile]
    
    init(numberOfPlayer: Int, startingLife: Int, colorPalette: Int, customProfiles: [PlayerCustomProfile], playWithTreachery: Bool) {
        self.numberOfPlayer = numberOfPlayer
        players = []
        
        var colors = [
            Color("\(colorPalette) Player 1"),
            Color("\(colorPalette) Player 2"),
            Color("\(colorPalette) Player 3"),
            Color("\(colorPalette) Player 4"),
            Color("\(colorPalette) Player 5"),
            Color("\(colorPalette) Player 6"),
            Color("\(colorPalette) Player 7"),
            Color("\(colorPalette) Player 8"),
        ]
        colors.shuffle()
        
        var treacheryRoles: [TreacheryPlayer.TreacheryRole] = []
        if playWithTreachery {
            treacheryRoles = TreacheryPlayer.getRandomizedRoleArray(nbrOfPlayer: numberOfPlayer)
        }
        
        for i in 1...numberOfPlayer {
            var backgroundImage: UIImage? = nil
            var name = "\("lifepoints_player".translate()) \(i)"
            var id = UUID()
            var profileIndex = -1
            for j in 0..<customProfiles.count {
                profileIndex = j
                let customProfile = customProfiles[j]
                if customProfile.lastUsedSlot == i - 1 {
                    name = customProfile.name
                    id = customProfile.id
                    if let imageData = customProfile.customImageData {
                        if let image = UIImage(data: imageData) {
                            backgroundImage = image
                        }
                    }
                }
            }
            
            var role: TreacheryPlayer? = nil
            if playWithTreachery {
                if treacheryRoles.count > 0 {
                    role = TreacheryPlayer(role: treacheryRoles.removeFirst())
                }
            }
            
            players.append(PlayerProfile(id: id, name: name, backgroundColor: colors[i - 1], backgroundImage: backgroundImage, lifePoints: startingLife, counters: PlayerCounters(), profileIndex: profileIndex, treachery: role))
        }
    }
}

struct PlayerProfile {
    var id: UUID
    var name: String
    var backgroundColor: Color
    var backgroundImage: UIImage?
    var lifePoints: Int
    var counters: PlayerCounters
    var profileIndex: Int
    var treachery: TreacheryPlayer?
}

struct PlayerCounters {
    var poison: Int = 0
    var commanderTax: Int = 0
    var commanderDamages: [Int] = [0, 0, 0, 0, 0, 0, 0, 0]
}
