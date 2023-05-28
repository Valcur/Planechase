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
                            LifePointsPlayerPanelView(playerId: i - 1, isMiniView: isMiniView, hasBeenChoosenRandomly: playersChoosenRandomly[i - 1])
                        }
                    }), row2:
                                    AnyView(HStack(spacing: 0) {
                        ForEach(1...halfNumberOfPlayers, id: \.self) { i in
                            LifePointsPlayerPanelView(playerId: i + halfNumberOfPlayers - 1, isMiniView: isMiniView, hasBeenChoosenRandomly: playersChoosenRandomly[i + halfNumberOfPlayers - 1])
                        }
                    }))
                } else {
                    UnevenBlueprint(row1: AnyView(HStack(spacing: 0) {
                        ForEach(1...halfNumberOfPlayers, id: \.self) { i in
                            LifePointsPlayerPanelView(playerId: i, isMiniView: isMiniView, hasBeenChoosenRandomly: playersChoosenRandomly[i])
                        }
                    }),
                                    row2: AnyView(                    HStack(spacing: 0) {
                        ForEach(1...halfNumberOfPlayers, id: \.self) { i in
                            LifePointsPlayerPanelView(playerId: i + halfNumberOfPlayers, isMiniView: isMiniView, hasBeenChoosenRandomly: playersChoosenRandomly[i + halfNumberOfPlayers])
                        }
                    }),
                                    sideElement: AnyView(LifePointsPlayerPanelView(playerId: 0, isMiniView: isMiniView, hasBeenChoosenRandomly: playersChoosenRandomly[0]))
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
                    }).position(x: geo.size.width - 40, y: geo.size.height - 40)
                }
            }.frame(width: geo.size.width, height: geo.size.height)
                .background(
                    VisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark)).opacity(isMiniView ? 0 : 1)
                )
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
    let blurEffect: UIBlurEffect.Style = .systemChromeMaterialDark
    let isMiniView: Bool
    let hasBeenChoosenRandomly: Bool
    @State var playerCounters = PlayerCounters()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if planechaseVM.lifeCounterOptions.colorPaletteId == -1 {
                VisualEffectView(effect: UIBlurEffect(style: blurEffect))
            } else {
                players[playerId].backgroundColor
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
                CommanderRecapView(playerId: playerId, lifePoints: $lifePoints, playerCounters: $playerCounters)
                    .padding(10)
                
                HStack(alignment: .center) {
                    Spacer()
                    CounterRecapView(value: playerCounters.poison, imageName: "Poison", size: 70)
                    Color.white.frame(width: 80).opacity(0)
                    CounterRecapView(value: playerCounters.commanderTax, imageName: "CommanderTax", size: 60)
                    Spacer()
                }
            }
            Color.white.opacity(hasBeenChoosenRandomly ? 1 : 0)
        }.cornerRadius(isMiniView ? 0 : 15).padding(isMiniView ? 0 : (UIDevice.isIPhone ? 2 : 10))
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
    
    struct CounterRecapView: View {
        let value: Int
        let imageName: String
        let size: CGFloat
        
        var body: some View {
            ZStack {
                Image(imageName)
                    .resizable()
                    .frame(width: size, height: size)
                    .foregroundColor(Color.white)
                    .opacity(0.5)
                
                Text("\(value)")
                    .title()
            }.opacity(value > 0 ? 1 : 0)
        }
    }
    
    struct CommanderRecapView: View {
        @EnvironmentObject var lifePointsViewModel: LifePointsViewModel
        var halfNumberOfPlayers: Int {
            lifePointsViewModel.numberOfPlayer / 2
        }
        var isPlayerOnTheSide: Bool {
            playerId == 0 && lifePointsViewModel.numberOfPlayer % 2 == 1
        }
        @State private var showingCountersSheet = false
        let playerId: Int
        @Binding var lifePoints: Int
        @Binding var playerCounters: PlayerCounters
        
        var body: some View {
            GeometryReader { geo in
                HStack(alignment: .bottom) {
                    Spacer()
                    ZStack {
                        Color.black.opacity(0.00001)
                        
                        if lifePointsViewModel.numberOfPlayer % 2 == 0 {
                            EvenBlueprint(row1: AnyView(HStack(spacing: 0) {
                                ForEach(1...halfNumberOfPlayers, id: \.self) { i in
                                    CommanderDamageRecapPanelView(damageTaken: $playerCounters.commanderDamages[i - 1])
                                        .commanderDamageToYourself(i - 1 == playerId)
                                }
                            }), row2: AnyView(HStack(spacing: 0) {
                                ForEach(1...halfNumberOfPlayers, id: \.self) { i in
                                    CommanderDamageRecapPanelView(damageTaken: $playerCounters.commanderDamages[i + halfNumberOfPlayers - 1])
                                        .commanderDamageToYourself(i + halfNumberOfPlayers - 1 == playerId)
                                }
                            }))
                        } else {
                            UnevenBlueprint(row1: AnyView(HStack(spacing: 0) {
                                ForEach(1...halfNumberOfPlayers, id: \.self) { i in
                                    CommanderDamageRecapPanelView(damageTaken: $playerCounters.commanderDamages[i])
                                        .commanderDamageToYourself(i == playerId)
                                }
                            }),
                                            row2: AnyView(                    HStack(spacing: 0) {
                                ForEach(1...halfNumberOfPlayers, id: \.self) { i in
                                    CommanderDamageRecapPanelView(damageTaken: $playerCounters.commanderDamages[i + halfNumberOfPlayers])
                                        .commanderDamageToYourself(i + halfNumberOfPlayers == playerId)
                                }
                            }),
                                            sideElement: AnyView(CommanderDamageRecapPanelView(damageTaken: $playerCounters.commanderDamages[0])                        .commanderDamageToYourself(0 == playerId))
                            )
                        }
                    }
                    .frame(maxWidth: 200).frame(height: UIDevice.isIPhone ? 80 : 100)
                    .rotationEffect(.degrees(isPlayerOnTheSide ? 90 : (playerId < halfNumberOfPlayers + lifePointsViewModel.numberOfPlayer % 2 ? 180 : 0)))
                    .frame(maxWidth: 200).frame(height: isPlayerOnTheSide ? 200 : (UIDevice.isIPhone ? 80 : 100))
                    // iPhone scaling
                    .offset(y: UIDevice.isIPhone ? (isPlayerOnTheSide ? -30 : 10) : 0)
                    .scaleEffect(UIDevice.isIPhone ? 0.6 : 1)
                    
                    .onTapGesture {
                        showingCountersSheet = true
                    }
                    .sheet(isPresented: $showingCountersSheet) {
                        CountersSheet(playerCounters: $playerCounters, lifePoints: $lifePoints, playerId: playerId)
                    }
                    if !isPlayerOnTheSide {
                        Spacer()
                    }
                }.frame(maxHeight: .infinity, alignment: isPlayerOnTheSide ? .center : .bottom)
            }
        }
        
        struct CounterView: View {
            let blurEffect: UIBlurEffect.Style = .systemThinMaterialDark
            let imageName: String
            let value: Int
            
            var body: some View {
                ZStack {
                    VisualEffectView(effect: UIBlurEffect(style: blurEffect))
                    VStack {
                        Image(imageName)
                        Text("\(value)")
                            .title()
                    }
                }.frame(width: 40)
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
                }.cornerRadius(10).padding(2)
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
                    
                    Spacer()
                }
                
                Text("\(lifepoints)")
                    .font(.system(size: UIDevice.isIPhone ? 40 : 60))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .offset(y: UIDevice.isIPhone ? -10 : 0)
                
                if !isMiniView {
                    Spacer()
                }
                
                Spacer()
            }
            
            
            if totalChange != 0 {
                VStack {
                    HStack {
                        Spacer()
                        Text(totalChange > 0  ? "+\(totalChange)" : "\(totalChange)")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(.trailing, 20).padding(.top, 20)
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
            players.append(PlayerProfile(name: "\("lifepoints_player".translate()) \(i)", backgroundImage: "erer", backgroundColor: colors[i - 1]))
        }
    }
}

struct PlayerProfile {
    var name: String
    var backgroundImage: String
    var backgroundColor: Color
}

struct PlayerCounters {
    var poison: Int = 0
    var commanderTax: Int = 0
    var commanderDamages: [Int] = [0, 0, 0, 0, 0, 0, 0, 0]
}
