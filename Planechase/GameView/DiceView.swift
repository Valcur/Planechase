//
//  DiceView.swift
//  Planechase
//
//  Created by Loic D on 21/02/2023.
//

import SwiftUI

struct DiceView: View {
    @EnvironmentObject var gameVM: GameViewModel
    @Binding var diceResult: Int
    var diceResultDescription: String {
        if diceResult == 1 {
            return "Chaos"
        } else if diceResult == 6 {
            return "Planechase"
        } else {
            return "Nothing"
        }
    }
    
    var body: some View {
        Button(action: {
            rollDice()
        }, label: {
            ZStack {
                VStack {
                    Spacer()
                    Text(diceResultDescription)
                        .foregroundColor(.white)
                        .font(.subheadline)
                        .padding(.vertical, 5)
                }
                
                if diceResult == 1 {
                    Image("Chaos")
                        .resizable()
                        .foregroundColor(.white)
                        .padding(20)
                } else if diceResult == 6 {
                    Image("Planechase")
                        .resizable()
                        .foregroundColor(.white)
                        .padding(20)
                } else {
                    Color.black.opacity(0.000001)
                }
            }
        })
        .disabled(gameVM.travelModeEnable)
        .frame(width: 120, height: 120)
        .background(
            VisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
                .cornerRadius(10)
                .shadowed()
        )
    }
    
    func rollDice() {
        withAnimation(.spring()) {
            gameVM.focusCenterToggler.toggle()
            diceResult = Int.random(in: 1...6)
        }
    }
}

struct DiceView_Previews: PreviewProvider {
    static var previews: some View {
        DicePreviewBinder()
            .environmentObject(GameViewModel())
    }
    
    struct DicePreviewBinder: View {
        @State var diceResult: Int = 1
        
        var body: some View {
            DiceView(diceResult: $diceResult)
        }
    }
}
