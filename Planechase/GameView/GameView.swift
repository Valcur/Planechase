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
    @State var diceResult: Int = -2
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                GradientView(gradientId: planechaseVM.gradientId)
                
                if !gameVM.isPlayingClassicMode {
                    BoardView()
                    
                    RecenterView()
                        .position(x: 40, y: geo.size.height - 40)
                } else {
                    // AT SOME POINT, WILL NEED TO REPLACE WITH A CUSTOM ZOOM VIEW
                    ZoomView(card: gameVM.cardToZoomIn)
                }
                
                ReturnToMenuView()
                    .position(x: geo.size.width - 40, y: 40)
                
                ToolView()
                    .position(x: geo.size.width - 40, y: geo.size.height - 40)
                
                if !gameVM.isPlayingClassicMode {
                    ZoomView(card: gameVM.cardToZoomIn)
                }
                
                DiceView(diceResult: $diceResult)
                    .position(x: diceViewPositionX(width: geo.size.width),
                              y:  diceViewPositionY(height: geo.size.height))
                
                GameInfoView()
                    .position(x: geo.size.width / 2, y: geo.size.height + 50)
            }.frame(width: geo.size.width, height: geo.size.height)
        }
        .onChange(of: diceResult) { _ in
            if diceResult == 6 {
                gameVM.toggleTravelMode()
            }
        }
    }
    
    func diceViewPositionX(width: CGFloat) -> CGFloat {
        if gameVM.cardToZoomIn == nil {
            return 70
        }
        
        if planechaseVM.zoomViewType == .four {
            return width / 2 - 140
        } else if planechaseVM.zoomViewType == .two {
            return width / 2
        } else {
            return 70
        }
    }
    
    func diceViewPositionY(height: CGFloat) -> CGFloat {
        if gameVM.cardToZoomIn == nil {
            return 70
        }
        
        if planechaseVM.zoomViewType == .four {
            return height / 2 - 5
        } else if planechaseVM.zoomViewType == .two {
            return 70
        } else {
            return 70
        }
    }
    
    struct BoardView: View {
        @EnvironmentObject var gameVM: GameViewModel
        
        private var mapSize: Int {
            gameVM.map.endIndex
        }
        private var gridItemLayout: [GridItem]  {
            Array(repeating: .init(.fixed(CardSizes.map.width + 10), spacing: 10), count: mapSize)
        }
        
        var body: some View {
            ScrollViewReader { focus in
                ScrollView([.horizontal, .vertical], showsIndicators: false) {
                    LazyVGrid(columns: gridItemLayout) {
                        ForEach(0..<gameVM.map.joined().count, id: \.self) { i in
                            ZStack {
                                if let card = gameVM.map[i % mapSize][i / mapSize] {
                                    if card.imageURL == "HELLRIDE" {
                                        HellrideCardView(card: card).transition(.scale.combined(with: .opacity))
                                    } else {
                                        CardView(card: card).transition(.scale.combined(with: .opacity))
                                    }
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
            return gameVM.map[i % mapSize][i / mapSize]?.id ?? "EMPTY_\(i)"
        }
    }
    
    struct CardView: View {
        @EnvironmentObject var gameVM: GameViewModel
        @ObservedObject var card: Card
        
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
                    gameVM.travelTo(card)
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
    
    struct HellrideCardView: View {
        @EnvironmentObject var gameVM: GameViewModel
        @ObservedObject var card: Card
        
        var body: some View {
            ZStack {
                Image("Hellride")
                    .resizable()
                Text("Hellride")
                    .title()
                    .offset(y: -30)
                Color.black
                    .opacity(0.00001)
            }
                .frame(width: CardSizes.map.width, height: CardSizes.map.height)
                .cornerRadius(CardSizes.map.cornerRadius)
                .padding(5)
                .overlay(
                    ZStack {
                        RoundedRectangle(cornerRadius: CardSizes.map.cornerRadius + 4)
                            .stroke((card.state == .pickable && gameVM.travelModeEnable) ? .clear : .clear, lineWidth: 4)
                    }
                )
                .onLongPressGesture(minimumDuration: 0.5) {
                    if gameVM.travelModeEnable && card.state == .pickable {
                        gameVM.travelTo(card)
                    }
                }
        }
    }
}
