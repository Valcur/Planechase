//
//  DiceOptions.swift
//  Planechase
//
//  Created by Loic D on 09/03/2023.
//

import SwiftUI

struct DiceOptions: Codable {
    var diceStyle: Int
    var diceColor: Int
    var numberOfFace: Int
    var useChoiceDiceFace: Bool
    
    static func getForegroundColor(_ colorId: Int) -> Color {
        switch colorId {
        case 1:
            return Color("DiceGold")
        case 2:
            return Color("DiceGold")
        case 3:
            return Color("DiceMetalLight")
        case 4:
            return Color("DicePurpleLight")
        case 5:
            return Color("DiceCopperLight")
        case 6:
            return Color("DiceWoodLight")
        case 7:
            return Color("DiceGreen")
        default:
            return .white
        }
    }
    
    static func getBackground(_ colorId: Int) -> AnyView {
        switch colorId {
        case 1:
            return AnyView(Color.black.opacity(0.3))
        case 2:
            return AnyView(Color("DiceGoldBlue").opacity(1))
        case 3:
            return AnyView(Color("DiceMetalDark").opacity(1))
        case 4:
            return AnyView(Color("DicePurpleDark").opacity(1))
        case 5:
            return AnyView(Color("DiceCopperDark").opacity(1))
        case 6:
            return AnyView(Color("DiceWoodDark").opacity(1))
        case 7:
            return AnyView(Color.black.opacity(0.6))
        default:
            return AnyView(Color.black.opacity(0.3))
        }
    }
}
