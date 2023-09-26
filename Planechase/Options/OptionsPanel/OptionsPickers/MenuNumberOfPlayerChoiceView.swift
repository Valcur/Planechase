//
//  MenuNumberOfPlayerChoiceView.swift
//  Planechase
//
//  Created by Loic D on 02/06/2023.
//

import SwiftUI

extension OptionsMenuView {
    struct MenuNumberOfPlayerChoiceView: View {
        @EnvironmentObject var planechaseVM: PlanechaseViewModel
        let numberOfPlayers: Int
        var isSelected: Bool {
            planechaseVM.lifeCounterOptions.nbrOfPlayers == numberOfPlayers
        }
        
        var body: some View {
            Button(action: {
                planechaseVM.setLifeOptions(LifeOptions(useLifeCounter: planechaseVM.lifeCounterOptions.useLifeCounter,
                                                        useCommanderDamages: planechaseVM.lifeCounterOptions.useCommanderDamages,
                                                        colorPaletteId: planechaseVM.lifeCounterOptions.colorPaletteId,
                                                        nbrOfPlayers: numberOfPlayers,
                                                        startingLife: planechaseVM.lifeCounterOptions.startingLife,
                                                        profiles: planechaseVM.lifeCounterOptions.profiles))
            }, label: {
                Text(" \(numberOfPlayers) ")
                    .font(.title2)
                    .fontWeight(isSelected ? .bold : .regular)
                    .foregroundColor(.white)
                    .opacity(isSelected ? 1 : 0.7)
            })
        }
    }
}
