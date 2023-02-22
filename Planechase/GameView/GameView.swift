//
//  GameView.swift
//  Planechase
//
//  Created by Loic D on 20/02/2023.
//

import SwiftUI

struct GameView: View {
    @EnvironmentObject var planechaseVM: PlanechaseViewModel
    @EnvironmentObject var gameVM: GameViewModel
    @State var diceResult: Int = 1
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                GradientView(gradientId: 1)
                
                BoardView()
                
                Button(action: {
                    planechaseVM.togglePlaying()
                }, label: {
                    Text("<").buttonLabel()
                }).position(x: 50, y: 50)
                
                ZoomView(card: gameVM.cardToZoomIn)
                
                DiceView(diceResult: $diceResult)
                    .position(x: geo.size.width / 2, y:  50)
            }.frame(width: geo.size.width, height: geo.size.height)
        }
        .onChange(of: diceResult) { _ in
            //if diceResult == 6 {
                gameVM.toggleTravelMode()
            //}
        }
    }
    
    struct BoardView: View {
        @EnvironmentObject var gameVM: GameViewModel
        
        private var gridItemLayout: [GridItem]  {
            Array(repeating: .init(.fixed(70), spacing: 190), count: 5)
        }
        
        var body: some View {
            ScrollView([.horizontal, .vertical], showsIndicators: false) {
                LazyVGrid(columns: gridItemLayout) {
                    ForEach(0..<gameVM.map.joined().count, id: \.self) { i in
                        ZStack {
                            if let card = gameVM.map[i % 5][i / 5] {
                                CardView(card: card, coord: Coord(x: i % 5, y: i / 5)).transition(.scale.combined(with: .opacity))
                            } else {
                                EmptyCardView()
                            }
                        }.id(cardId(i))
                        
                    }
                }
            }
        }
        
        func cardId(_ i: Int) -> String {
            return gameVM.map[i % 5][i / 5]?.id ?? "\(i)"
        }
    }
    
    struct CardView: View {
        @EnvironmentObject var gameVM: GameViewModel
        @ObservedObject var card: Card
        var coord: Coord
        
        var body: some View {
            ZStack {
                if card.image == nil {
                    Color.black
                        .opacity(0.0000001)
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
            }
            .padding(5)
            .overlay(
                ZStack {
                    RoundedRectangle(cornerRadius: 19)
                        .stroke((card.state == .selected && !gameVM.travelModeEnable) ? .white : .clear, lineWidth: 4)
                    RoundedRectangle(cornerRadius: 19)
                        .stroke((card.state == .pickable && gameVM.travelModeEnable) ? .white : .clear, lineWidth: 4)
                }
            )
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.3)) {
                    gameVM.cardToZoomIn = card.new()
                }
            }
            .onLongPressGesture(minimumDuration: 0.5) {
                if gameVM.travelModeEnable && card.state == .pickable {
                    gameVM.travelTo(coord)
                }
            }
        }
    }
    
    struct EmptyCardView: View {
        var body: some View {
            Color.black
                .frame(width: 250, height: 180)
                .cornerRadius(15)
                .padding(5)
        }
    }
}
