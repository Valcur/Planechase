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
    static let biggerCardsOnMapCoeff: CGFloat = 1.3
    let lifePointsViewModel: LifePointsViewModel
    
    init(lifeCounterOptions: LifeOptions) {
        lifePointsViewModel = LifePointsViewModel(numberOfPlayer: lifeCounterOptions.nbrOfPlayers,
                                                  startingLife: lifeCounterOptions.startingLife, colorPalette: lifeCounterOptions.colorPaletteId)
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                if !gameVM.isPlayingClassicMode && !planechaseVM.lifeCounterOptions.useLifeCounter {
                    RecenterView()
                        .position(x: planechaseVM.lifeCounterOptions.useLifeCounter ? 120 : 40, y: geo.size.height - 40)
                } else {
                    ZoomView(card: gameVM.cardToZoomIn)
                }
                
                ReturnToMenuView()
                    .position(x: geo.size.width - 40, y: 40)
                
                if !gameVM.isPlayingClassicMode {
                    ZoomView(card: gameVM.cardToZoomIn)
                }
                
                ToolView()
                    .position(x: geo.size.width - 40, y: geo.size.height - 40)
                
                DiceView(diceResult: $diceResult)
                    .position(x: diceViewPositionX(width: geo.size.width),
                              y:  diceViewPositionY(height: geo.size.height))
                
                GameInfoView()
                    .position(x: geo.size.width / 2, y: geo.size.height + 50)
                
                CurrentOtherPlanesView()
                    .position(x: diceViewPositionX(width: geo.size.width),
                              y:  diceViewPositionY(height: geo.size.height))
                    
                LifePointsView()
                    .environmentObject(lifePointsViewModel)
                    .opacity(gameVM.showLifePointsView ? 1 : 0)
                    
                if planechaseVM.lifeCounterOptions.useLifeCounter {
                    LifePointsToggleView()
                        .environmentObject(lifePointsViewModel)
                }
                
                PlanarDeckControlView()
            }
        }.background(
            ZStack {
                GradientView(gradientId: planechaseVM.gradientId)
                
                if !gameVM.isPlayingClassicMode {
                    BoardView()
                }
            }.ignoresSafeArea()
        )
        .onChange(of: diceResult) { _ in
            if diceResult == 2 {
                gameVM.toggleTravelMode()
            }
        }
    }
    
    func diceViewPositionX(width: CGFloat) -> CGFloat {
        if gameVM.cardToZoomIn == nil {
            return 70
        }
        
        if planechaseVM.zoomViewType == .four {
            return width / 2 - 160
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
        @EnvironmentObject var planechaseVM: PlanechaseViewModel
        @EnvironmentObject var gameVM: GameViewModel
        
        private var coeff: CGFloat {
            return planechaseVM.biggerCardsOnMap ? GameView.biggerCardsOnMapCoeff : 1
        }
        private var mapSize: Int {
            gameVM.map.endIndex
        }
        private var gridItemLayout: [GridItem]  {
            Array(repeating: .init(.fixed(CardSizes.map.scaledWidth(coeff) + 10), spacing: 10), count: mapSize)
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
        @EnvironmentObject var planechaseVM: PlanechaseViewModel
        @EnvironmentObject var gameVM: GameViewModel
        @ObservedObject var card: Card
        private var coeff: CGFloat {
            return planechaseVM.biggerCardsOnMap ? GameView.biggerCardsOnMapCoeff : 1
        }
        
        var body: some View {
            ZStack {
                if card.image == nil {
                    Color.black
                        .opacity(0.0000001)
                        .frame(width: CardSizes.map.scaledWidth(coeff), height: CardSizes.map.scaledHeight(coeff))
                        .cornerRadius(CardSizes.map.scaledRadius(coeff))
                        .shadowed(radius: 8)
                        .onAppear {
                            card.cardAppears()
                        }
                } else {
                    Image(uiImage: card.image!)
                        .resizable()
                        .frame(width: CardSizes.map.scaledWidth(coeff), height: CardSizes.map.scaledHeight(coeff))
                        .cornerRadius(CardSizes.map.scaledRadius(coeff))
                        .shadowed(radius: 8)
                }
            }
            .padding(5)
            .overlay(
                ZStack {
                    RoundedRectangle(cornerRadius: CardSizes.map.cornerRadius + CardSizes.selectionBorderAdditionalCornerRadius)
                        .stroke((card.state == .selected && !gameVM.travelModeEnable) ? .white : .clear, lineWidth: 4)
                    RoundedRectangle(cornerRadius: CardSizes.map.cornerRadius + CardSizes.selectionBorderAdditionalCornerRadius)
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
        @EnvironmentObject var planechaseVM: PlanechaseViewModel
        private var coeff: CGFloat {
            return planechaseVM.biggerCardsOnMap ? GameView.biggerCardsOnMapCoeff : 1
        }
        
        var body: some View {
            Color.black
                .opacity(0.0000001)
                .frame(width: CardSizes.map.scaledWidth(coeff), height: CardSizes.map.scaledHeight(coeff))
                .cornerRadius(CardSizes.map.scaledRadius(coeff))
                .padding(5)
        }
    }
    
    struct HellrideCardView: View {
        @EnvironmentObject var planechaseVM: PlanechaseViewModel
        @EnvironmentObject var gameVM: GameViewModel
        @ObservedObject var card: Card
        private var coeff: CGFloat {
            return planechaseVM.biggerCardsOnMap ? GameView.biggerCardsOnMapCoeff : 1
        }
        
        var body: some View {
            ZStack {
                if planechaseVM.useHellridePNG {
                    Image("Hellride")
                        .resizable()
                    Text("game_hellride_title".translate())
                        .title()
                        .offset(y: -30)
                    Color.black
                        .opacity(0.00001)
                } else {
                    Color.black
                        .opacity(0.3)
                    
                    Text("game_hellride_title".translate())
                        .title()
                }
            }
            .frame(width: CardSizes.map.scaledWidth(coeff), height: CardSizes.map.scaledHeight(coeff))
            .cornerRadius(CardSizes.map.scaledRadius(coeff))
            .padding(5)
            .overlay(
                ZStack {
                    RoundedRectangle(cornerRadius: CardSizes.map.cornerRadius + CardSizes.selectionBorderAdditionalCornerRadius)
                        .stroke((card.state == .pickable && gameVM.travelModeEnable && !planechaseVM.useHellridePNG) ? .white : .clear, lineWidth: 4)
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
