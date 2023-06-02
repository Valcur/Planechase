//
//  MenuCustomDiceChoiceView.swift
//  Planechase
//
//  Created by Loic D on 02/06/2023.
//

import SwiftUI

extension OptionsMenuView {
    struct MenuCustomDiceChoiceView: View {
        @EnvironmentObject var planechaseVM: PlanechaseViewModel
        let diceStyleId: Int
        
        var body: some View {
            Button(action: {
                print("Changing dice style to \(diceStyleId)")
                planechaseVM.setDiceOptions(DiceOptions(diceStyle: diceStyleId,
                                                        diceColor: planechaseVM.diceOptions.diceColor,
                                                        numberOfFace: planechaseVM.diceOptions.numberOfFace,
                                                        useChoiceDiceFace: planechaseVM.diceOptions.useChoiceDiceFace))
            }, label: {
                ZStack {
                    DiceOptions.getBackground(planechaseVM.diceOptions.diceColor)
                    
                    Image("Choice")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(DiceOptions.getForegroundColor(planechaseVM.diceOptions.diceColor))
                        .padding(10)
                    
                    DiceOverlay(diceStyleId: diceStyleId, diceColorId: planechaseVM.diceOptions.diceColor)
                }.frame(width: 73, height: 73)
                    .cornerRadius(8)
                    .padding(8)
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(planechaseVM.diceOptions.diceStyle == diceStyleId ? .white : .clear, lineWidth: 4))
            })
        }
    }
}
