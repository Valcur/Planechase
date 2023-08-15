//
//  DiceView.swift
//  Planechase
//
//  Created by Loic D on 02/06/2023.
//

import SwiftUI

struct DiceView: View {
    @EnvironmentObject var planechaseVM: PlanechaseViewModel
    @EnvironmentObject var gameVM: GameViewModel
    @Binding var diceResult: Int
    @State private var animationAmount = 0.0
    @State var rollCost: Int = 0
    var diceResultDescription: String {
        if diceResult == -1 {
            return ""
        } else if diceResult == -2 {
            return "game_dice_pressToRoll".translate()
        } else if diceResult == 1 {
            return "game_dice_chaos".translate()
        } else if diceResult == 2 {
            return "game_dice_planechase".translate()
        } else if diceResult == 3 {
            return "game_dice_choice".translate()
        } else {
            return "game_dice_nothing".translate()
        }
    }
    
    var body: some View {
        ZStack {
            DismissCostView(rollCost: $rollCost, diceResult: $diceResult)
                .offset(y: rollCost > 0 ? 100 : 0)
                .opacity(rollCost > 0 ? 1 : 0)
            
            Button(action: {
                rollDice()
            }, label: {
                ZStack {
                    VStack {
                        Spacer()
                        Text(diceResultDescription)
                            .foregroundColor(.white)
                            .font(.subheadline)
                            .padding(.vertical, 3)
                    }
                    
                    ZStack {
                        DiceOptions.getBackground(planechaseVM.diceOptions.diceColor)
                        
                        DiceOverlay(diceStyleId: planechaseVM.diceOptions.diceStyle, diceColorId: planechaseVM.diceOptions.diceColor)
                        
                        if diceResult == 1 {
                            Image("Chaos")
                                .resizable()
                                .renderingMode(.template)
                                .foregroundColor(DiceOptions.getForegroundColor(planechaseVM.diceOptions.diceColor))
                                .padding(10)
                        } else if diceResult == 2 {
                            Image("Planechase")
                                .resizable()
                                .renderingMode(.template)
                                .foregroundColor(DiceOptions.getForegroundColor(planechaseVM.diceOptions.diceColor))
                                .padding(5)
                        }
                        else if diceResult == 3 {
                           Image("Choice")
                               .resizable()
                               .renderingMode(.template)
                               .foregroundColor(DiceOptions.getForegroundColor(planechaseVM.diceOptions.diceColor))
                               .padding(10)
                       }
                    }.frame(width: 73, height: 73)
                    .cornerRadius(8)
                    .rotation3DEffect(.degrees(animationAmount), axis: (x: 0, y: 0, z: 1))

                    Text(rollCost > 0 ? "\(rollCost)" : "").headline().position(x: 13, y: 13)
                }.transition(.scale.combined(with: .opacity))
            })
            .disabled(gameVM.travelModeEnable)
            .frame(width: 120, height: 120)
            .background(
                VisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
                    .cornerRadius(10)
                    .shadowed()
            )
        }
    }
    
    func rollDice() {
        guard diceResult != -1 else { return }
        animationAmount = 0
        withAnimation(.spring()) {
            diceResult = -1
            self.animationAmount += 360
            rollCost += 1
        }
        
        let diceNumberOfFace = planechaseVM.diceOptions.numberOfFace

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeIn(duration: 0.1)) {
                gameVM.focusCenterToggler.toggle()
                diceResult = Int.random(in: 1...diceNumberOfFace)
                if !planechaseVM.diceOptions.useChoiceDiceFace && diceResult == 3 {
                    diceResult = diceNumberOfFace
                }
            }
        }
    }
    
    struct DismissCostView: View {
        @Binding var rollCost: Int
        @Binding var diceResult: Int
        var body: some View {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    rollCost = 0
                    diceResult = 0
                }
            }, label: {
                Text("game_dice_resetCost".translate()).textButtonLabel()
            })
        }
    }
}
