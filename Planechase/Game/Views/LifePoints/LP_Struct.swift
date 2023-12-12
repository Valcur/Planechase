//
//  LP_Structs.swift
//  LifeCounter
//
//  Created by Loic D on 31/10/2023.
//

import Foundation

struct LastUsedSetup: Codable {
    var playersProfilesIds: [UUID?]
    var partnerEnabled: [Bool]
    var alternativeCountersEnabled: [[String]]
    
    static func getDefaultSetup() -> LastUsedSetup {
        return LastUsedSetup(playersProfilesIds: Array.init(repeating: nil, count: 8),
                             partnerEnabled: Array.init(repeating: false, count: 8),
                             alternativeCountersEnabled: Array.init(repeating: ["Poison", "Tax"], count: 8))
    }
}

struct LifeOptions: Codable {
    var useLifeCounter: Bool
    var useCommanderDamages: Bool
    var colorPaletteId: Int
    var nbrOfPlayers: Int
    var startingLife: Int
    var backgroundStyleId: Int
    var autoHideLifepointsCooldown: Double
    var useMonarchToken: Bool
    var monarchTokenStyleId: Int
}

struct TreacheryOptions: Codable {
    var isTreacheryEnabled: Bool
    var isUsingUnco: Bool
    var isUsingRare: Bool
    var isUsingMythic: Bool
}
