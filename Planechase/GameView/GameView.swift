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
        
        private var mapSize: Int {
            gameVM.map.endIndex
        }
        private var gridItemLayout: [GridItem]  {
            Array(repeating: .init(.fixed(CardSizes.map.width), spacing: 10), count: mapSize)
        }
        
        var body: some View {
            ScrollViewReader { focus in
                ScrollView([.horizontal, .vertical], showsIndicators: false) {
                    LazyVGrid(columns: gridItemLayout) {
                        ForEach(0..<gameVM.map.joined().count, id: \.self) { i in
                            ZStack {
                                if let card = gameVM.map[i % mapSize][i / mapSize] {
                                    CardView(card: card, coord: Coord(x: i % mapSize, y: i / mapSize)).transition(.scale.combined(with: .opacity))
                                } else {
                                    EmptyCardView()
                                }
                            }.id(cardId(i))
                        }
                    }
                    .onChange(of: gameVM.focusCenterToggler) { _ in
                        withAnimation(.easeInOut(duration: 0.3)) {
                            focus.scrollTo(gameVM.getCenter().id, anchor: .center)
                        }
                    }
                    .onAppear() {
                        focus.scrollTo(gameVM.getCenter().id, anchor: .center)
                    }
                }
            }
        }
        
        func cardId(_ i: Int) -> String {
            return gameVM.map[i % mapSize][i / mapSize]?.id ?? "\(i)"
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
                        .frame(width: CardSizes.map.width, height: CardSizes.map.height)
                        .cornerRadius(CardSizes.map.cornerRadius)
                        .shadowed(radius: 8)
                        .onAppear {
                            card.cardAppears()
                        }
                } else {
                    Image(uiImage: card.image!)
                        .resizable()
                        .frame(width: CardSizes.map.width, height: CardSizes.map.height)
                        .cornerRadius(CardSizes.map.cornerRadius)
                        .shadowed(radius: 8)
                }
            }
            .padding(5)
            .overlay(
                ZStack {
                    RoundedRectangle(cornerRadius: CardSizes.map.cornerRadius + 4)
                        .stroke((card.state == .selected && !gameVM.travelModeEnable) ? .white : .clear, lineWidth: 4)
                    RoundedRectangle(cornerRadius: CardSizes.map.cornerRadius + 4)
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
                .opacity(0.0000001)
                .frame(width: CardSizes.map.width, height: CardSizes.map.height)
                .cornerRadius(CardSizes.map.cornerRadius)
                .padding(5)
        }
    }
}
