//
//  LifePointsView.swift
//  Planechase
//
//  Created by Loic D on 30/04/2023.
//

import SwiftUI

struct LifePointsView: View {
    @EnvironmentObject var lifePointsViewModel: LifePointsViewModel
    var halfNumberOfPlayers: Int {
        lifePointsViewModel.numberOfPlayer / 2
    }
    let isMiniView: Bool
    
    init(isMiniView: Bool = false) {
        self.isMiniView = isMiniView
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                if lifePointsViewModel.numberOfPlayer % 2 == 0 {
                EvenBlueprint(row1:
                                AnyView(HStack(spacing: 0) {
                    ForEach(1...halfNumberOfPlayers, id: \.self) { i in
                        LifePointsPlayerPanelView(playerId: i - 1, isMiniView: isMiniView)
                    }
                }), row2:
                                AnyView(HStack(spacing: 0) {
                    ForEach(1...halfNumberOfPlayers, id: \.self) { i in
                        LifePointsPlayerPanelView(playerId: i + halfNumberOfPlayers - 1, isMiniView: isMiniView)
                    }
                }))
                } else {
                    UnevenBlueprint(row1: AnyView(HStack(spacing: 0) {
                        ForEach(1...halfNumberOfPlayers, id: \.self) { i in
                            LifePointsPlayerPanelView(playerId: i, isMiniView: isMiniView)
                        }
                    }),
                                    row2: AnyView(                    HStack(spacing: 0) {
                        ForEach(1...halfNumberOfPlayers, id: \.self) { i in
                            LifePointsPlayerPanelView(playerId: i + halfNumberOfPlayers, isMiniView: isMiniView)
                        }
                    }),
                                    sideElement: AnyView(LifePointsPlayerPanelView(playerId: 0, isMiniView: isMiniView))
                    )
                }
            }.frame(width: geo.size.width, height: geo.size.height)
                .background(
                    VisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark)).ignoresSafeArea().opacity(isMiniView ? 0 : 1)
                )
        }
    }
}

struct EvenBlueprint: View {
    @EnvironmentObject var lifePointsViewModel: LifePointsViewModel
    let row1: AnyView
    let row2: AnyView
    
    var body: some View {
        VStack(spacing: 0) {
            row1.rotationEffect(.degrees(180))
            row2
        }.ignoresSafeArea()
    }
}

struct UnevenBlueprint: View {
    @EnvironmentObject var lifePointsViewModel: LifePointsViewModel
    let row1: AnyView
    let row2: AnyView
    let sideElement: AnyView

    var unevenScalerDivider: CGFloat {
        let nbrOfPlayer = lifePointsViewModel.numberOfPlayer
        if nbrOfPlayer == 5 {
            return 2.4
        } else  if nbrOfPlayer == 7 {
            return 3
        }
        return 2
    }
    
    var body: some View {
        GeometryReader { geo in
            HStack(spacing: 0) {
                VStack {
                    row1.rotationEffect(.degrees(180))
                    row2
                }
                sideElement
                    .frame(width: geo.size.height, height: geo.size.height / unevenScalerDivider)
                    .rotationEffect(.degrees(-90))
                    .frame(width: geo.size.height / unevenScalerDivider)
            }
        }.ignoresSafeArea()
    }
}

struct LifePointsPlayerPanelView: View {
    @EnvironmentObject var planechaseVM: PlanechaseViewModel
    @EnvironmentObject var lifePointsViewModel: LifePointsViewModel
    let playerId: Int
    var players: [PlayerProfile] {
        lifePointsViewModel.players
    }
    var playerName: String {
        players[playerId].name
    }
    @State var lifePoints: Int = 40
    @State var prevValue: CGFloat = 0
    @State var totalChange: Int = 0
    @State var totalChangeTimer: Timer?
    let randomColors = [Color.red, Color.green, Color.yellow, Color.blue, Color.black]
    @State var commanderDamages: [Int] = [0, 0, 0, 0, 0, 0, 0, 0]
    let blurEffect: UIBlurEffect.Style = .systemThinMaterialDark
    let isMiniView: Bool
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if planechaseVM.lifeCounterOptions.colorPaletteId == 0 {
                VisualEffectView(effect: UIBlurEffect(style: blurEffect)).cornerRadius(isMiniView ? 0 : 15)
            } else {
                players[playerId].backgroundColor.cornerRadius(isMiniView ? 0 : 15)
            }
            LifePointsPanelView(playerName: playerName, lifepoints: $lifePoints, totalChange: $totalChange, isMiniView: isMiniView).cornerRadius(15)
            VStack(spacing: 0) {
                Rectangle()
                    .opacity(0.0001)
                    .onTapGesture {
                        addLifepoint()
                        startTotalChangeTimer()
                    }
                Rectangle()
                    .opacity(0.0001)
                    .onTapGesture {
                        removeLifepoint()
                        startTotalChangeTimer()
                    }
            }
            if planechaseVM.lifeCounterOptions.useCommanderDamages && !isMiniView {
                CommanderDamagesRecapView(playerId: playerId, lifePoints: $lifePoints, commanderDamages: $commanderDamages)
            }
        }.padding(isMiniView ? 0 : 10)
        .gesture(DragGesture()
            .onChanged { value in
                let newValue = value.translation.height
                if newValue > prevValue + 10 {
                    prevValue = newValue
                    removeLifepoint()
                }
                else if newValue < prevValue - 10 {
                    prevValue = newValue
                    addLifepoint()
                }
            }
            .onEnded({ _ in
                startTotalChangeTimer()
            })
        )
    }
    
    private func addLifepoint() {
        totalChangeTimer?.invalidate()
        lifePoints += 1
        totalChange += 1
    }
    
    private func removeLifepoint() {
        totalChangeTimer?.invalidate()
        if lifePoints > 0 {
            lifePoints -= 1
            totalChange -= 1
        }
    }
    
    private func startTotalChangeTimer() {
        totalChangeTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { timer in
            totalChange = 0
        }
    }
    
    struct CommanderDamagesRecapView: View {
        @EnvironmentObject var lifePointsViewModel: LifePointsViewModel
        let blurEffect: UIBlurEffect.Style = .systemThinMaterialDark
        var halfNumberOfPlayers: Int {
            lifePointsViewModel.numberOfPlayer / 2
        }
        @State private var showingCountersSheet = false
        let playerId: Int
        @Binding var lifePoints: Int
        @Binding var commanderDamages: [Int]
        
        var body: some View {
            ZStack {
                VisualEffectView(effect: UIBlurEffect(style: blurEffect)).opacity(0.000001)
                
                if lifePointsViewModel.numberOfPlayer % 2 == 0 {
                    EvenBlueprint(row1: AnyView(HStack {
                        ForEach(1...halfNumberOfPlayers, id: \.self) { i in
                            CommanderDamageRecapPanelView(damageTaken: $commanderDamages[i - 1])
                                .commanderDamageToYourself(i - 1 == playerId)
                        }
                    }), row2: AnyView(HStack {
                        ForEach(1...halfNumberOfPlayers, id: \.self) { i in
                            CommanderDamageRecapPanelView(damageTaken: $commanderDamages[i + halfNumberOfPlayers - 1])
                                .commanderDamageToYourself(i + halfNumberOfPlayers - 1 == playerId)
                        }
                    }))
                } else {
                    UnevenBlueprint(row1: AnyView(HStack {
                        ForEach(1...halfNumberOfPlayers, id: \.self) { i in
                            CommanderDamageRecapPanelView(damageTaken: $commanderDamages[i])
                                .commanderDamageToYourself(i == playerId)
                        }
                    }),
                                    row2: AnyView(                    HStack {
                        ForEach(1...halfNumberOfPlayers, id: \.self) { i in
                            CommanderDamageRecapPanelView(damageTaken: $commanderDamages[i + halfNumberOfPlayers])
                                .commanderDamageToYourself(i + halfNumberOfPlayers == playerId)
                        }
                    }),
                                    sideElement: AnyView(CommanderDamageRecapPanelView(damageTaken: $commanderDamages[0])                        .commanderDamageToYourself(0 == playerId))
                    )
                }
            }.frame(width: 200, height: 100).rotationEffect(.degrees(playerId == 0 && lifePointsViewModel.numberOfPlayer % 2 == 1 ? 90 : (playerId < halfNumberOfPlayers + lifePointsViewModel.numberOfPlayer % 2 ? 180 : 0))).offset(x: playerId == 0 && lifePointsViewModel.numberOfPlayer % 2 == 1 ? 100 : 0, y: playerId == 0 && lifePointsViewModel.numberOfPlayer % 2 == 1 ? -60 : -10)
                .onTapGesture {
                    showingCountersSheet = true
                }
                .sheet(isPresented: $showingCountersSheet) {
                    CountersSheet(commanderDamages: $commanderDamages, lifePoints: $lifePoints, playerId: playerId)
                }
        }
        
        struct CommanderDamageRecapPanelView: View {
            let blurEffect: UIBlurEffect.Style = .systemThinMaterialDark
            @Binding var damageTaken: Int
            
            var body: some View {
                ZStack {
                    VisualEffectView(effect: UIBlurEffect(style: blurEffect))
                    Text("\(damageTaken)")
                        .font(.title2)
                        .foregroundColor(.white)
                }.cornerRadius(10).padding(5)
            }
        }
        
        struct CountersSheet: View {
            @EnvironmentObject var lifePointsViewModel: LifePointsViewModel
            @Environment(\.presentationMode) var presentationMode
            var halfNumberOfPlayers: Int {
                lifePointsViewModel.numberOfPlayer / 2
            }
            @Binding var commanderDamages: [Int]
            @Binding var lifePoints: Int
            let playerId: Int
            
            var body: some View {
                VStack {
                    ZStack {
                        if lifePointsViewModel.numberOfPlayer % 2 == 0 {
                            EvenBlueprint(row1: AnyView(HStack {
                                ForEach(1...halfNumberOfPlayers, id: \.self) { i in
                                    CommanderDamage(damageTaken: $commanderDamages[i - 1], lifePoints: $lifePoints)
                                        .commanderDamageToYourself(i - 1 == playerId)
                                }
                            }), row2: AnyView(HStack {
                                ForEach(1...halfNumberOfPlayers, id: \.self) { i in
                                    CommanderDamage(damageTaken: $commanderDamages[i + halfNumberOfPlayers - 1], lifePoints: $lifePoints)
                                        .commanderDamageToYourself(i + halfNumberOfPlayers - 1 == playerId)
                                }
                            }))
                        } else {
                            UnevenBlueprint(row1: AnyView(HStack {
                                ForEach(1...halfNumberOfPlayers, id: \.self) { i in
                                    CommanderDamage(damageTaken: $commanderDamages[i], lifePoints: $lifePoints)
                                        .commanderDamageToYourself(i == playerId)
                                }
                            }),
                                            row2: AnyView(                    HStack {
                                ForEach(1...halfNumberOfPlayers, id: \.self) { i in
                                    CommanderDamage(damageTaken: $commanderDamages[i + halfNumberOfPlayers], lifePoints: $lifePoints)
                                        .commanderDamageToYourself(i + halfNumberOfPlayers == playerId)
                                }
                            }),
                                            sideElement: AnyView(CommanderDamage(damageTaken: $commanderDamages[0], lifePoints: $lifePoints)
                                                .commanderDamageToYourself(0 == playerId))
                            )
                        }
                    }.padding(.horizontal, 100).frame(height: 300)
                }
            }
            
            struct CommanderDamage: View {
                let blurEffect: UIBlurEffect.Style = .systemThinMaterialDark
                @Binding var damageTaken: Int
                @Binding var lifePoints: Int
                
                var body: some View {
                    ZStack {
                        VisualEffectView(effect: UIBlurEffect(style: blurEffect))
                        Text("\(damageTaken)")
                            .font(.title2)
                            .foregroundColor(.white)
                    }.cornerRadius(10).padding(5)
                        .onTapGesture {
                            damageTaken += 1
                            lifePoints -= 1
                        }
                }
            }
        }
    }
}

extension View {
    func commanderDamageToYourself(_ isYourself: Bool) -> some View {
        self.opacity(isYourself ? 0.5 : 1)
    }
}

struct LifePointsPanelView: View {
    @EnvironmentObject var lifePointsViewModel: LifePointsViewModel
    
    let playerName: String
    @Binding var lifepoints: Int
    @Binding var totalChange: Int
    let isMiniView: Bool
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                
                if !isMiniView {
                    Text(playerName)
                        .font(.title3)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Text("\(lifepoints)")
                    .font(.system(size: 60))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Spacer()
            }
            
            
            if totalChange != 0 {
                VStack {
                    HStack {
                        Text(totalChange > 0  ? "+\(totalChange)" : "\(totalChange)")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(.leading, 20).padding(.top, 20)
                        Spacer()
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
    @Published var startLife: Int
    @Published var numberOfPlayer: Int
    @Published var players: [PlayerProfile]
    
    init(numberOfPlayer: Int, startingLife: Int, colorPalette: Int) {
        self.numberOfPlayer = numberOfPlayer
        self.startLife = startingLife
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
            players.append(PlayerProfile(name: "Player \(i)", backgroundImage: "erer", backgroundColor: colors[i - 1]))
        }
    }
}

struct PlayerProfile {
    var name: String
    var backgroundImage: String
    var backgroundColor: Color
}
