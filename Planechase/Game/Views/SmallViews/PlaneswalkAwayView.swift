//
//  PlaneswalkAwayView.swift
//  Planechase
//
//  Created by Loic D on 21/11/2023.
//

import SwiftUI

struct PlaneswalkAwayView: View {
    @EnvironmentObject var planechaseVM: PlanechaseViewModel
    @EnvironmentObject var gameVM: GameViewModel
    @State var showView: Bool = false
    var foregroundColor: Color {
        DiceOptions.getForegroundColor(planechaseVM.diceOptions.diceColor)
    }
    
    var body: some View {
        Button(action: {
            if showView {
                withAnimation(.easeInOut(duration: 0.3)) {
                    gameVM.planeswalkAwayFromPhenomenon()
                }
            }
        }, label: {
            ZStack {
                Image("Planechase")
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(foregroundColor)
                    .scaledToFill()
                    .padding(20)
                
                VStack {
                    Text("Planeswalk")
                        .font(.headline)
                        .fontWeight(.regular)
                        .foregroundColor(foregroundColor)
                    
                    Spacer()
                    
                    Text("Away")
                        .font(.headline)
                        .fontWeight(.regular)
                        .foregroundColor(foregroundColor)
                        
                }.padding(5)
            }
        })
        .frame(width: 120, height: 120)
        .background(
            ZStack {
                Color.black
                DiceOptions.getBackground(planechaseVM.diceOptions.diceColor)
            }.cornerRadius(10)
        )
        .opacity(showView ? 1 : 0)
        .onChange(of: gameVM.cardToZoomIn?.id) { card in
            updateOpacity()
        }
        .onAppear() {
            updateOpacity()
        }
    }
    
    func updateOpacity() {
        withAnimation(.easeInOut(duration: 0.5)) {
            if gameVM.isPlayingClassicMode {
                if let cardType = gameVM.cardToZoomIn?.cardType {
                    showView = cardType == .phenomenon
                } else {
                    showView = false
                }
            } else {
                if let cardType = gameVM.getCenter().cardType {
                    showView = cardType == .phenomenon
                } else {
                    showView = false
                }
            }
        }
    }
}
