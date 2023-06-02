//
//  DiceOverlay.swift
//  Planechase
//
//  Created by Loic D on 02/06/2023.
//

import SwiftUI

struct DiceOverlay: View {
    let diceStyleId: Int
    let diceColorId: Int
    var body: some View {
        ZStack {
            if diceStyleId > 0 {
                if diceStyleId <= 4 {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(DiceOptions.getForegroundColor(diceColorId), lineWidth: 2)
                    
                    CornerImage(diceStyle: diceStyleId, diceColorId: diceColorId, alignment: .topLeading)
                    CornerImage(diceStyle: diceStyleId, diceColorId: diceColorId, alignment: .topTrailing)
                    CornerImage(diceStyle: diceStyleId, diceColorId: diceColorId, alignment: .bottomLeading)
                    CornerImage(diceStyle: diceStyleId, diceColorId: diceColorId, alignment: .bottomTrailing)
                } else {
                    if diceStyleId == 5 {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(DiceOptions.getForegroundColor(diceColorId), lineWidth: 4)
                        
                        Image("Gear")
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(DiceOptions.getForegroundColor(diceColorId))
                            .scaleEffect(1.1)
                    } else if diceStyleId == 6 {
                        Image("ArtDeco1")
                            .resizable()
                            .renderingMode(.template)
                            .scaledToFit()
                            .foregroundColor(DiceOptions.getForegroundColor(diceColorId))
                            .scaleEffect(0.9)
                    } else if diceStyleId == 7 {
                        Image("ArtDeco2")
                            .resizable()
                            .renderingMode(.template)
                            .scaledToFit()
                            .foregroundColor(DiceOptions.getForegroundColor(diceColorId))
                    } else if diceStyleId == 8 {
                        Image("LOTR2")
                            .resizable()
                            .renderingMode(.template)
                            .scaledToFit()
                            .foregroundColor(DiceOptions.getForegroundColor(diceColorId))
                            .scaleEffect(1)
                        Image("LOTR1")
                            .resizable()
                            .renderingMode(.template)
                            .scaledToFit()
                            .foregroundColor(DiceOptions.getForegroundColor(diceColorId))
                            .scaleEffect(0.88)
                    } else if diceStyleId == 9 {
                        Image("LOTR1")
                            .resizable()
                            .renderingMode(.template)
                            .scaledToFit()
                            .foregroundColor(DiceOptions.getForegroundColor(diceColorId))
                            .scaleEffect(0.95)
                    } else if diceStyleId == 10 {
                        Image("minimalist1")
                            .resizable()
                            .renderingMode(.template)
                            .scaledToFit()
                            .foregroundColor(DiceOptions.getForegroundColor(diceColorId))
                            .scaleEffect(0.95)
                    } else if diceStyleId == 11 {
                        Image("minimalist2")
                            .resizable()
                            .renderingMode(.template)
                            .scaledToFit()
                            .foregroundColor(DiceOptions.getForegroundColor(diceColorId))
                            .scaleEffect(1.1)
                    }
                }
            }
        }
    }
    
    struct CornerImage: View {
        let diceStyle: Int
        let diceColorId: Int
        let alignment: Alignment
        var rotation: Double {
            if alignment == .topLeading {
                return 90
            } else if alignment == .topTrailing {
                return 180
            } else if alignment == .bottomLeading {
                return 0
            } else {
                return 270
            }
        }
        var imageName: String {
            return "Corner\(diceStyle)"
        }
        
        var body: some View {
            ZStack() {
                Image(imageName)
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(DiceOptions.getForegroundColor(diceColorId))
                    .frame(width: 30, height: 30)
                    .rotationEffect(.degrees(rotation))
            }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignment).padding(4)
        }
    }
}
