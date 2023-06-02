//
//  CurrentOtherPlanesView.swift
//  Planechase
//
//  Created by Loic D on 21/02/2023.
//

import SwiftUI

struct CurrentOtherPlanesView: View {
    @EnvironmentObject var gameVM: GameViewModel
    
    var body: some View {
        GeometryReader { geo in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(gameVM.otherCurrentPlanes, id:\.id) { card in
                        Button(action: {
                            gameVM.switchToOtherCurrentPLane(card)
                        }, label: {
                            if card.image == nil {
                                Color.black
                                    .frame(width: CardSizes.widthtForHeight(60), height: 60)
                                    .cornerRadius(CardSizes.cornerRadiusForWidth(CardSizes.widthtForHeight(60)))
                                    .onAppear {
                                        card.cardAppears()
                                    }
                            } else {
                                Image(uiImage: card.image!)
                                    .resizable()
                                    .frame(width: CardSizes.widthtForHeight(60), height: 60)
                                    .cornerRadius(CardSizes.cornerRadiusForWidth(CardSizes.widthtForHeight(60)))
                            }
                        }).shadowed(radius: 2, y: 2).padding(5)
                    }
                    
                    if gameVM.otherCurrentPlanes.count > 0 {
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                gameVM.otherCurrentPlanes = []
                            }
                        }, label: {
                            Text("discard".translate()).textButtonLabel()
                        })
                    }
                }
            }.frame(maxWidth: geo.size.width / 3).offset(x: geo.size.width / 2 + 80, y: geo.size.height / 2 - 30)
        }
    }
}
