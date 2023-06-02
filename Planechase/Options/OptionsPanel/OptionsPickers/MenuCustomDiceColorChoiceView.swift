//
//  MenuCustomDiceColorChoiceView.swift
//  Planechase
//
//  Created by Loic D on 02/06/2023.
//

import SwiftUI

extension OptionsMenuView {
    struct MenuCustomDiceColorChoiceView: View {
        @EnvironmentObject var planechaseVM: PlanechaseViewModel
        let diceColorId: Int
        
        var body: some View {
            Button(action: {
                print("Changing dice color to \(diceColorId)")
                planechaseVM.setDiceOptions(DiceOptions(diceStyle: planechaseVM.diceOptions.diceStyle,
                                                        diceColor: diceColorId,
                                                        numberOfFace: planechaseVM.diceOptions.numberOfFace,
                                                        useChoiceDiceFace: planechaseVM.diceOptions.useChoiceDiceFace))
            }, label: {
                ZStack {
                    DiceOptions.getBackground(diceColorId)
                    
                    Image("Choice")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(DiceOptions.getForegroundColor(diceColorId))
                        .padding(10)
                    
                    DiceOverlay(diceStyleId: planechaseVM.diceOptions.diceStyle, diceColorId: diceColorId)
                }.frame(width: 73, height: 73)
                    .cornerRadius(8)
                    .padding(8)
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(planechaseVM.diceOptions.diceColor == diceColorId ? .white : .clear, lineWidth: 4))
            })
        }
    }
}
