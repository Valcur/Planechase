//
//  MonarchTokenView.swift
//  Planechase
//
//  Created by Loic D on 05/10/2023.
//

import SwiftUI

struct MonarchTokenView: View {
    @EnvironmentObject var planechaseVM: PlanechaseViewModel
    @Binding var lifepointHasBeenUsedToggler: Bool
    @State var isDragging = false
    @State private var offset = CGSize.zero
    @State private var newset = CGSize.zero
    @State var reverseCrown = false
    
    var body: some View {
        MonarchTokenStyle(styleId: planechaseVM.lifeCounterOptions.monarchTokenStyleId)
        .rotationEffect(.degrees(reverseCrown ? 180 : 0))
        .shadowed()
        .offset(x: offset.width, y: offset.height)
        .gesture(
            DragGesture()
                .onChanged { g in
                    offset = CGSize(width: g.translation.width + newset.width, height: g.translation.height + newset.height)
                    withAnimation(.easeInOut(duration: 0.3)) {
                        reverseCrown = offset.height <= 0
                    }
                    lifepointHasBeenUsedToggler.toggle()
                }
                .onEnded { _ in
                    newset = offset
                }
        )
    }
}

struct MonarchTokenStyle: View {
    let styleId: Int
    let blurEffect: UIBlurEffect.Style = .systemThinMaterialDark
    let tokenSize: CGFloat = 80
    var body: some View {
        ZStack {
            if styleId == 0 {
                VisualEffectView(effect: UIBlurEffect(style: blurEffect))
                Circle().stroke(Color("DiceGold"), lineWidth: 3).frame(width: 77, height: 77)
                Circle().stroke(Color("DiceGold"), lineWidth: 3).frame(width: 65, height: 65)
                Image("Crown 1")
                    .resizable()
                    .scaledToFill()
                    .colorMultiply(Color("DiceGold"))
                    .padding(20)
            } else if styleId == -1 {
                VisualEffectView(effect: UIBlurEffect(style: blurEffect))
                Image(systemName: "crown.fill")
                    .resizable()
                    .scaledToFill()
                    .foregroundColor(.white)
                    .padding(25)
            } else if styleId == 1 {
                VisualEffectView(effect: UIBlurEffect(style: blurEffect))
                Circle().foregroundColor(Color("DiceGold")).opacity(0.3)
                                         
                Circle().stroke(Color("DiceGold"), lineWidth: 8).frame(width: tokenSize - 8, height: tokenSize - 8)
                
                Image("Crown 1")
                    .resizable()
                    .scaledToFill()
                    .colorMultiply(Color("DiceGold"))
                    .padding(15)
            } else if styleId == 2 {
                Image("Crown 1")
                    .resizable()
                    .scaledToFill()
                    .colorMultiply(Color.white)
                    .padding(0)
            }
        }
        .frame(width: tokenSize, height: tokenSize)
        .cornerRadius(tokenSize / 2)
    }
}
