//
//  MenuLifeCounterBackgroundColorChoiceView.swift
//  Planechase
//
//  Created by Loic D on 02/06/2023.
//

import SwiftUI

extension OptionsMenuView {
    struct MenuLifeCounterBackgroundColorChoiceView: View {
        @EnvironmentObject var planechaseVM: PlanechaseViewModel
        let blurEffect: UIBlurEffect.Style = .systemThinMaterialDark
        let colorId: Int
        var isUserAllowed: Bool {
            return planechaseVM.isPremium || colorId < 1
        }
        
        var body: some View {
            ZStack {
                Button(action: {
                    print("Changing life counter color to \(colorId)")
                    planechaseVM.setLifeOptions(LifeOptions(useLifeCounter: planechaseVM.lifeCounterOptions.useLifeCounter,
                                                            useCommanderDamages: planechaseVM.lifeCounterOptions.useCommanderDamages,
                                                            colorPaletteId: colorId,
                                                            nbrOfPlayers: planechaseVM.lifeCounterOptions.nbrOfPlayers,
                                                            startingLife: planechaseVM.lifeCounterOptions.startingLife, profiles: planechaseVM.lifeCounterOptions.profiles))
                }, label: {
                    VStack {
                        if colorId == -1 {
                            VisualEffectView(effect: UIBlurEffect(style: blurEffect))
                        } else {
                            HStack {
                                Color("\(colorId) Player 1")
                                Color("\(colorId) Player 2")
                                Color("\(colorId) Player 3")
                                Color("\(colorId) Player 4")
                            }
                            HStack {
                                Color("\(colorId) Player 5")
                                Color("\(colorId) Player 6")
                                Color("\(colorId) Player 7")
                                Color("\(colorId) Player 8")
                            }
                        }
                    }.cornerRadius(15).frame(width: 120, height: 120).overlay(
                        RoundedRectangle(cornerRadius: 19)
                            .stroke(planechaseVM.lifeCounterOptions.colorPaletteId == colorId ? .white : .clear, lineWidth: 4))
                    .padding(10)
                }).disabled(!isUserAllowed).opacity(isUserAllowed ? 1 : 0.6)
                
                if !isUserAllowed {
                    Image(systemName: "crown.fill")
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .position(x: 10, y: 10)
                }
            }
        }
    }
}
