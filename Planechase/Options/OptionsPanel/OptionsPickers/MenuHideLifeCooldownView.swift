//
//  MenuHideLifeCooldownView.swift
//  Planechase
//
//  Created by Loic D on 05/10/2023.
//

import SwiftUI

extension OptionsMenuView {
    struct MenuHideLifeCooldownView: View {
        @EnvironmentObject var planechaseVM: PlanechaseViewModel
        let cooldown: Double
        var isSelected: Bool {
            planechaseVM.lifeCounterOptions.autoHideLifepointsCooldown == cooldown
        }
        
        var body: some View {
            Button(action: {
                var lifeTmp = planechaseVM.lifeCounterOptions
                lifeTmp.autoHideLifepointsCooldown = cooldown
                planechaseVM.setLifeOptions(lifeTmp)
            }, label: {
                Text(" \(cooldown == -1 ? "disabled".translate() : "\(Int(cooldown))") ")
                    .font(.title2)
                    .fontWeight(isSelected ? .bold : .regular)
                    .foregroundColor(.white)
                    .opacity(isSelected ? 1 : 0.7)
            })
        }
    }
}
