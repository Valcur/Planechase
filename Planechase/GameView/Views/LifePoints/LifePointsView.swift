//
//  LifePointsView.swift
//  Planechase
//
//  Created by Loic D on 30/04/2023.
//

import SwiftUI

struct LifePointsView: View {
    @EnvironmentObject var gameVM: GameViewModel
    @EnvironmentObject var lifePointsViewModel: LifePointsViewModel
    var halfNumberOfPlayers: Int {
        lifePointsViewModel.numberOfPlayer / 2
    }
    let isMiniView: Bool
    @State var playersChoosenRandomly: [Bool]

    
    init(isMiniView: Bool = false) {
        self.isMiniView = isMiniView
        playersChoosenRandomly = Array(repeating: false, count: 8)
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                if lifePointsViewModel.numberOfPlayer % 2 == 0 {
                    EvenBlueprint(row1:
                                    AnyView(HStack(spacing: 0) {
                        ForEach(1...halfNumberOfPlayers, id: \.self) { i in
                            LifePointsPlayerPanelView(playerId: i - 1, player: $lifePointsViewModel.players[i - 1], isMiniView: isMiniView, hasBeenChoosenRandomly: playersChoosenRandomly[i - 1])
                        }
                    }), row2:
                                    AnyView(HStack(spacing: 0) {
                        ForEach(1...halfNumberOfPlayers, id: \.self) { i in
                            LifePointsPlayerPanelView(playerId: i + halfNumberOfPlayers - 1, player: $lifePointsViewModel.players[i + halfNumberOfPlayers - 1], isMiniView: isMiniView, hasBeenChoosenRandomly: playersChoosenRandomly[i + halfNumberOfPlayers - 1])
                        }
                    }))
                } else {
                    UnevenBlueprint(row1: AnyView(HStack(spacing: 0) {
                        ForEach(1...halfNumberOfPlayers, id: \.self) { i in
                            LifePointsPlayerPanelView(playerId: i, player: $lifePointsViewModel.players[i], isMiniView: isMiniView, hasBeenChoosenRandomly: playersChoosenRandomly[i])
                        }
                    }),
                                    row2: AnyView(                    HStack(spacing: 0) {
                        ForEach(1...halfNumberOfPlayers, id: \.self) { i in
                            LifePointsPlayerPanelView(playerId: i + halfNumberOfPlayers, player: $lifePointsViewModel.players[i + halfNumberOfPlayers], isMiniView: isMiniView, hasBeenChoosenRandomly: playersChoosenRandomly[i + halfNumberOfPlayers])
                        }
                    }),
                                    sideElement: AnyView(LifePointsPlayerPanelView(playerId: 0, player: $lifePointsViewModel.players[0], isMiniView: isMiniView, hasBeenChoosenRandomly: playersChoosenRandomly[0]))
                    )
                }
                if !isMiniView {
                    Button(action: {
                        let player = Int.random(in: 0..<lifePointsViewModel.numberOfPlayer)
                        playersChoosenRandomly[player] = true
                        withAnimation(.easeInOut(duration: 1).delay(0.15)) {
                            playersChoosenRandomly[player] = false
                        }
                    }, label: {
                        Image(systemName: "dice.fill")
                            .imageButtonLabel()
                    }).position(x: geo.size.width - 35, y: geo.size.height - 35)
                    
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            gameVM.showLifePointsView.toggle()
                        }
                    }, label: {
                        Image(systemName: "xmark")
                            .imageButtonLabel()
                    }).position(x: 35, y: geo.size.height - 35)
                }
            }.frame(width: geo.size.width, height: geo.size.height)
                .background(
                    VisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark)).opacity(isMiniView ? 0 : 1)
                )
        }.ignoresSafeArea()
    }
}

extension View {
    func commanderDamageToYourself(_ isYourself: Bool) -> some View {
        self.opacity(isYourself ? 0.4 : 1)
    }
}

struct LifePointsPanelView: View {
    @EnvironmentObject var lifePointsViewModel: LifePointsViewModel
    
    let playerName: String
    @Binding var lifepoints: Int
    @Binding var totalChange: Int
    let isMiniView: Bool
    let inverseChangeSide: Bool
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                
                if !isMiniView {
                    Text(playerName)
                        .font(.title3)
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                
                Text("\(lifepoints)")
                    .font(.system(size: isMiniView ? 80 : (UIDevice.isIPhone ? 40 : 60)))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .offset(y: UIDevice.isIPhone && !isMiniView ? -10 : 0)
                
                if !isMiniView {
                    Spacer()
                }
                
                Spacer()
            }
            
            
            if totalChange != 0 {
                VStack {
                    HStack {
                        if !(inverseChangeSide) {
                            Spacer()
                        }
                        Text(totalChange > 0  ? "+\(totalChange)" : "\(totalChange)")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(20)
                        if inverseChangeSide {
                            Spacer()
                        }
                    }
                    Spacer()
                }
            }
        }
    }
}

struct LifePointsView_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 15.0, *) {
            LifePointsView()
                .previewInterfaceOrientation(.landscapeLeft)
                .environmentObject(LifePointsViewModel(numberOfPlayer: 5, startingLife: 60, colorPalette: 1))
        } else {
            LifePointsView()
                .environmentObject(LifePointsViewModel(numberOfPlayer: 5, startingLife: 60, colorPalette: 1))
        }
    }
}

class LifePointsViewModel: ObservableObject {
    @Published var numberOfPlayer: Int
    @Published var players: [PlayerProfile]
    
    init(numberOfPlayer: Int, startingLife: Int, colorPalette: Int) {
        self.numberOfPlayer = numberOfPlayer
        players = []
        
        var colors = [
            Color("\(colorPalette) Player 1"),
            Color("\(colorPalette) Player 2"),
            Color("\(colorPalette) Player 3"),
            Color("\(colorPalette) Player 4"),
            Color("\(colorPalette) Player 5"),
            Color("\(colorPalette) Player 6"),
            Color("\(colorPalette) Player 7"),
            Color("\(colorPalette) Player 8"),
        ]
        colors.shuffle()
        for i in 1...numberOfPlayer {
            players.append(PlayerProfile(name: "\("lifepoints_player".translate()) \(i)", backgroundColor: colors[i - 1], lifePoints: startingLife, counters: PlayerCounters()))
        }
    }
}

struct PlayerProfile {
    var name: String
    var backgroundColor: Color
    var lifePoints: Int
    var counters: PlayerCounters
}

struct PlayerCounters {
    var poison: Int = 0
    var commanderTax: Int = 0
    var commanderDamages: [Int] = [0, 0, 0, 0, 0, 0, 0, 0]
}
