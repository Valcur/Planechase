//
//  MonarchTokenView.swift
//  Planechase
//
//  Created by Loic D on 05/10/2023.
//

import SwiftUI

struct MonarchTokenView: View {
    @EnvironmentObject var planechaseVM: PlanechaseViewModel
    @EnvironmentObject var lifePointsViewModel: LifePointsViewModel
    @Binding var lifepointHasBeenUsedToggler: Bool
    @State var isDragging = false
    @State private var offset = CGSize.zero
    @State private var newset = CGSize.zero
    @State var crownRotation: CGFloat = 0
    
    var unevenScalerDivider: CGFloat {
        let nbrOfPlayer = lifePointsViewModel.numberOfPlayer
        if nbrOfPlayer == 5 {
            return UIDevice.isIPhone ? 1.95 : 2.6
        }
        return UIDevice.isIPhone ? 1.4 : 2
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                MonarchTokenStyle(styleId: planechaseVM.lifeCounterOptions.monarchTokenStyleId)
                    .rotationEffect(.degrees(crownRotation))
                    .shadowed()
                    .offset(x: offset.width, y: offset.height)
                    .gesture(
                        DragGesture()
                            .onChanged { g in
                                if !isDragging {
                                    isDragging = true
                                    lifepointHasBeenUsedToggler.toggle()
                                }
                                offset = CGSize(width: g.translation.width + newset.width, height: g.translation.height + newset.height)
                            }
                            .onEnded { g in
                                updateMonarchId(width: geo.size.width, height: geo.size.height)
                                newset = offset
                                lifepointHasBeenUsedToggler.toggle()
                                isDragging = false
                            }
                    )
            }.frame(width: geo.size.width, height: geo.size.height)
        }
    }
    
    private func updateMonarchId(width: CGFloat, height: CGFloat) {
        var remainingWidth = width
        let posX = offset.width + width / 2
        let posY = offset.height
        let unevenLimit = lifePointsViewModel.numberOfPlayer % 2 == 1 ? height / unevenScalerDivider : 0
        var newCrownRotation = crownRotation
        
        if posX > remainingWidth - unevenLimit {
            lifePointsViewModel.currentMonarchId = 0
            newCrownRotation = -90
        } else {
            remainingWidth = remainingWidth - unevenLimit
            let evenNumberOfPlayersPerRow = (lifePointsViewModel.numberOfPlayer - lifePointsViewModel.numberOfPlayer % 2) / 2
            let segmentWidth = remainingWidth / CGFloat(evenNumberOfPlayersPerRow)
            let player = Int(posX / segmentWidth)
            
            let evenFixer = lifePointsViewModel.numberOfPlayer % 2 == 1 ? 0 : 1
            
            if posY < 0 {
                setNewMonarch(id: evenNumberOfPlayersPerRow - player - evenFixer)
                newCrownRotation = 180
            } else {
                setNewMonarch(id: evenNumberOfPlayersPerRow + player + 1 - evenFixer)
                newCrownRotation = 0
            }
        }
        
        withAnimation(.easeInOut(duration: 0.3)) {
            crownRotation = newCrownRotation
        }
    }
    
    private func setNewMonarch(id: Int) {
        withAnimation(.easeInOut(duration: 0.3)) {
            lifePointsViewModel.currentMonarchId = id
        }
    }
}

struct MonarchTokenStyle: View {
    let styleId: Int
    let blurEffect: UIBlurEffect.Style = .systemThinMaterialDark
    let tokenSize: CGFloat = 80
    var body: some View {
        ZStack {
            if styleId == -1 {
                VisualEffectView(effect: UIBlurEffect(style: blurEffect)).cornerRadius(tokenSize / 2)
                Image("Crown 1")
                    .resizable()
                    .scaledToFill()
                    .colorMultiply(.white)
                    .padding(20)
            } else if styleId == 0 {
                VisualEffectView(effect: UIBlurEffect(style: blurEffect)).cornerRadius(tokenSize / 2)
                Circle().stroke(Color("DiceGold"), lineWidth: 3).frame(width: 77, height: 77)
                Circle().stroke(Color("DiceGold"), lineWidth: 3).frame(width: 65, height: 65)
                Image("Crown 1")
                    .resizable()
                    .scaledToFill()
                    .colorMultiply(Color("DiceGold"))
                    .padding(20)
            } else if styleId == 1 {
                VisualEffectView(effect: UIBlurEffect(style: blurEffect)).cornerRadius(tokenSize / 2)
                Circle().foregroundColor(Color("DiceGold")).opacity(0.3)
                                         
                Circle().stroke(Color("DiceGold"), lineWidth: 8).frame(width: tokenSize - 8, height: tokenSize - 8)
                
                Image("Crown 1")
                    .resizable()
                    .scaledToFill()
                    .colorMultiply(Color("DiceGold"))
                    .padding(15)
            } else if styleId == 2 {
                ZStack {
                    Color("MTBorder").cornerRadius(10)
                    Color("MTBackground").cornerRadius(7).padding(5)
                }.padding(10).rotationEffect(.degrees(-45))
                Image("Crown 2")
                    .resizable()
                    .scaledToFill()
                    .colorMultiply(Color("MTCrown"))
                    .padding(20)
            } else if styleId == 3 {
                Image("Crown 3")
                    .resizable()
                    .scaledToFill()
                    .padding(0)
            } else if styleId == 4 {
                VisualEffectView(effect: UIBlurEffect(style: blurEffect)).cornerRadius(tokenSize / 2)
                ZStack {
                    Circle().stroke(Color("DiceRedFront"), lineWidth: 3).frame(width: 71, height: 71)
                    
                    Image("King")
                        .resizable()
                        .scaledToFill()
                        .colorMultiply(Color("DiceRedFront"))
                        .padding(10)
                        .offset(y: 10)
                }.frame(width: tokenSize - 6, height: tokenSize - 6).cornerRadius(tokenSize / 2)
            }
        }
        .frame(width: tokenSize, height: tokenSize).clipped()
    }
}
