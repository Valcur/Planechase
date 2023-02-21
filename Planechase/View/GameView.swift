//
//  GameView.swift
//  Planechase
//
//  Created by Loic D on 20/02/2023.
//

import SwiftUI

struct GameView: View {
    @EnvironmentObject var planechaseVM: PlanechaseViewModel
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                GradientView(gradientId: 1)
                
                BoardView().frame(width: geo.size.width, height: geo.size.height)
                
                Button(action: {
                    planechaseVM.togglePlaying()
                }, label: {
                    Text("<").buttonLabel()
                }).position(x: 50, y: 50)
            }
        }
    }
    
    struct BoardView: View {
        @EnvironmentObject var gameVM: GameViewModel
        
        var body: some View {
            ScrollView([.horizontal, .vertical], showsIndicators: false) {
                VStack {
                    ForEach(0..<gameVM.map.endIndex, id: \.self) { i in
                         HStack {
                             ForEach(0..<gameVM.map.endIndex, id: \.self) { j in
                                 if let card = gameVM.map[i][j] {
                                     CardView(card: card)
                                 } else {
                                     EmptyCardView()
                                 }
                             }
                         }
                    }
                }
            }
        }
    }
    
    struct CardView: View {
        @ObservedObject var card: Card
        
        var body: some View {
            Button(action: {

            }, label: {
                if card.image == nil {
                    Color.black
                        .frame(width: 250, height: 180)
                        .cornerRadius(15)
                        .onAppear {
                            card.cardAppears()
                        }
                } else {
                    card.image!
                        .resizable()
                        .frame(width: 250, height: 180)
                        .cornerRadius(15)
                }
            })
            .padding(5)
            .overlay(
                RoundedRectangle(cornerRadius: 19)
                    .stroke(card.state == .selected ? .white : .clear, lineWidth: 4)
            )
        }
    }
    
    struct EmptyCardView: View {
        var body: some View {
            Color.black
                .frame(width: 250, height: 180)
                .cornerRadius(15)
        }
    }
}
