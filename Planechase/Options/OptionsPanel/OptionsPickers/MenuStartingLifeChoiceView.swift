//
//  MenuStartingLifeChoiceView.swift
//  Planechase
//
//  Created by Loic D on 02/06/2023.
//

import SwiftUI

extension OptionsMenuView {
    struct MenuStartingLifeChoiceView: View {
        @EnvironmentObject var planechaseVM: PlanechaseViewModel
        let startingLife: Int
        var isSelected: Bool {
            planechaseVM.lifeCounterOptions.startingLife == startingLife
        }
        
        var body: some View {
            Button(action: {
                var lifeTmp = planechaseVM.lifeCounterOptions
                lifeTmp.startingLife = startingLife
                planechaseVM.setLifeOptions(lifeTmp)
            }, label: {
                Text(" \(startingLife) ")
                    .font(.title2)
                    .fontWeight(isSelected ? .bold : .regular)
                    .foregroundColor(.white)
                    .opacity(isSelected ? 1 : 0.7)
            })
        }
    }
}
