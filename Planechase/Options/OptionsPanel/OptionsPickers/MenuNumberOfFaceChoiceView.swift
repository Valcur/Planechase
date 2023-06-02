//
//  MenuNumberOfFaceChoiceView.swift
//  Planechase
//
//  Created by Loic D on 02/06/2023.
//

import SwiftUI

extension OptionsMenuView {
    struct MenuNumberOfFaceChoiceView: View {
        @EnvironmentObject var planechaseVM: PlanechaseViewModel
        let numberOfFace: Int
        var isSelected: Bool {
            planechaseVM.diceOptions.numberOfFace == numberOfFace
        }
        
        var body: some View {
            Button(action: {
                planechaseVM.setDiceOptions(DiceOptions(diceStyle: planechaseVM.diceOptions.diceStyle,
                                                        diceColor: planechaseVM.diceOptions.diceColor,
                                                        numberOfFace: numberOfFace,
                                                        useChoiceDiceFace: planechaseVM.diceOptions.useChoiceDiceFace))
            }, label: {
                Text("\(numberOfFace)")
                    .font(.title2)
                    .fontWeight(isSelected ? .bold : .regular)
                    .foregroundColor(.white)
                    .opacity(isSelected ? 1 : 0.7)
            })
        }
    }
}
