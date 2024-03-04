//
//  CommanderDamagesPanel.swift
//  Planechase
//
//  Created by Loic D on 25/05/2023.
//

import SwiftUI

extension LifePointsPlayerPanelView {
    struct CommanderDamagesPanel: View {
        @EnvironmentObject var lifePointsViewModel: LifePointsViewModel
        var halfNumberOfPlayers: Int {
            lifePointsViewModel.numberOfPlayer / 2
        }
        @State var exitTimer: Timer?
        @Binding var showSheet: Bool
        @Binding var playerCounters: PlayerCounters
        @Binding var lifePoints: Int
        let playerId: Int
        let isFullscreen: Bool
        let playerProfiles: [PlayerProfile]
        
        var body: some View {
            ZStack {
                if !isFullscreen && playerId == 0 && lifePointsViewModel.numberOfPlayer % 2 == 1 {
                    HStack(spacing: 20) {
                        Spacer()
                        VStack {
                            Spacer()
                            PartnerSwitch(playerId: playerId)
                            Spacer()
                        }
                        Spacer()
                        CommanderVStack(playerCounters: $playerCounters, lifePoints: $lifePoints, playerId: playerId, isFullscreen: isFullscreen, playerProfiles: playerProfiles)
                            .frame(maxWidth: UIDevice.isIPhone ? .infinity : 200)
                        Spacer()
                    }.padding(5)
                } else {
                    VStack(spacing: UIDevice.isIPhone ? 0 : 20) {
                        CommanderVStack(playerCounters: $playerCounters, lifePoints: $lifePoints, playerId: playerId, isFullscreen: isFullscreen, playerProfiles: playerProfiles)
                        Spacer()
                        PartnerSwitch(playerId: playerId)
                    }.padding(5)//.padding(.vertical, UIDevice.isIPhone ? 10 : 0)
                }
            }.background(Color.black)
            .onAppear() {
                exitTimer?.invalidate()
                startExitTimer()
            }
            .onChange(of: playerCounters.commanderDamages) { _ in
                exitTimer?.invalidate()
                startExitTimer()
            }
        }
        
        private func startExitTimer() {
            exitTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { timer in
                withAnimation(.easeInOut(duration: 0.3)) {
                    showSheet = false
                }
            }
        }
        
        struct PartnerSwitch: View {
            @EnvironmentObject var lifePointsViewModel: LifePointsViewModel
            let playerId: Int
            var isEnabled: Bool {
                if lifePointsViewModel.players.count > playerId {
                    return lifePointsViewModel.players[playerId].counters.commanderDamages[playerId].count == 2
                }
                return false
            }
            
            var body: some View {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        lifePointsViewModel.togglePartnerForPlayer(playerId)
                        lifePointsViewModel.savePartnerForPlayer(playerId)
                    }
                }, label: {
                    Text("\(isEnabled ? "Disable" : "Enable") partner")
                        .textButtonLabel()
                })
            }
        }
        
        struct CommanderVStack: View {
            @EnvironmentObject var lifePointsViewModel: LifePointsViewModel
            var halfNumberOfPlayers: Int {
                lifePointsViewModel.numberOfPlayer / 2
            }
            @Binding var playerCounters: PlayerCounters
            @Binding var lifePoints: Int
            let playerId: Int
            let isFullscreen: Bool
            let playerProfiles: [PlayerProfile]
            
            var rotationAngle: Double {
                if lifePointsViewModel.numberOfPlayer % 2 == 1 {
                    if playerId == 0 {
                        return 90
                    } else if playerId <= halfNumberOfPlayers {
                        return 180
                    } else {
                        return 0
                    }
                } else {
                    if playerId < halfNumberOfPlayers {
                        return 180
                    } else {
                        return 0
                    }
                }
            }
            
            var body: some View {
                GeometryReader { geo in
                    let isOnTheSide = rotationAngle == 90
                    let size = geo.size
                    ZStack {
                        if lifePointsViewModel.numberOfPlayer % 2 == 0 {
                            EvenBlueprint(row1: AnyView(HStack(spacing: 0) {
                                ForEach(1...halfNumberOfPlayers, id: \.self) { i in
                                    CommanderDamage(damageTaken: $playerCounters.commanderDamages[i - 1],
                                                    lifePoints: $lifePoints,
                                                    isFullscreen: isFullscreen,
                                                    playerProfile: playerProfiles[i - 1]
                                    )
                                        .commanderDamageToYourself(i - 1 == playerId)
                                }
                            }), row2: AnyView(HStack(spacing: 0) {
                                ForEach(1...halfNumberOfPlayers, id: \.self) { i in
                                    CommanderDamage(damageTaken: $playerCounters.commanderDamages[i + halfNumberOfPlayers - 1],
                                                    lifePoints: $lifePoints,
                                                    isFullscreen: isFullscreen,
                                                    playerProfile: playerProfiles[i + halfNumberOfPlayers - 1]
                                    )
                                        .commanderDamageToYourself(i + halfNumberOfPlayers - 1 == playerId)
                                }
                            }))
                        } else {
                            UnevenBlueprint(row1: AnyView(HStack(spacing: 0) {
                                ForEach(1...halfNumberOfPlayers, id: \.self) { i in
                                    CommanderDamage(damageTaken: $playerCounters.commanderDamages[i],
                                                    lifePoints: $lifePoints,
                                                    isFullscreen: isFullscreen,
                                                    playerProfile: playerProfiles[i]
                                    )
                                        .commanderDamageToYourself(i == playerId)
                                }
                            }),
                                            row2: AnyView(                    HStack(spacing: 0) {
                                ForEach(1...halfNumberOfPlayers, id: \.self) { i in
                                    CommanderDamage(damageTaken: $playerCounters.commanderDamages[i + halfNumberOfPlayers],
                                                    lifePoints: $lifePoints,
                                                    isFullscreen: isFullscreen,
                                                    playerProfile: playerProfiles[i + halfNumberOfPlayers]
                                    )
                                        .commanderDamageToYourself(i + halfNumberOfPlayers == playerId)
                                }
                            }),
                                            sideElement: AnyView(CommanderDamage(damageTaken: $playerCounters.commanderDamages[0],
                                                                                 lifePoints: $lifePoints,
                                                                                 isFullscreen: isFullscreen,
                                                                                 playerProfile: playerProfiles[0]
                                                                                )
                                                .commanderDamageToYourself(0 == playerId))
                            )
                        }
                    }
                    .rotationEffect(.degrees(isOnTheSide ? 90 : 0), anchor: .topLeading)
                    .rotationEffect(.degrees(rotationAngle == 180 ? 180 : 0), anchor: .center)
                    .frame(width: isOnTheSide ? size.height : size.width, height: isOnTheSide ? size.width : size.height)
                    .offset(x: isOnTheSide ? size.width : 0, y: 0)
                }
            }
        }
        
        struct CommanderDamage: View {
            let blurEffect: UIBlurEffect.Style = .systemUltraThinMaterialDark
            @Binding var damageTaken: [Int]
            @Binding var lifePoints: Int
            let isFullscreen: Bool
            @State var playerProfile: PlayerProfile
            
            var body: some View {
                HStack(spacing: 2) {
                    ForEach(0..<damageTaken.count, id: \.self) { i in
                        if isFullscreen || true {
                            FullScreenCommanderDamages(damageTaken: $damageTaken[i], lifePoints: $lifePoints)
                        } else {
                            ZStack {
                                Color.black.opacity(0.5)
                                Text("\(damageTaken[i])")
                                    .font(.title2)
                                    .foregroundColor(.white)
                            }
                            .onTapGesture {
                                damageTaken[i] += 1
                                lifePoints -= 1
                            }
                            .onLongPressGesture(minimumDuration: 0.1) {
                                lifePoints += damageTaken[i]
                                damageTaken[i] = 0
                            }
                        }
                    }
                }
                .background(
                    LifePointsPanelBackground(player: $playerProfile, isMiniView: true, isPlayerOnOppositeSide: false)
                )
                .cornerRadius(10)
                .clipped()
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.white, lineWidth: 1)
                )
                .padding(3)
            }
        }
        
        struct FullScreenCommanderDamages: View {
            @Binding var damageTaken: Int
            @Binding var lifePoints: Int
            @State var topPressed = false
            @State var bottomPressed = false
            @State var topPressedTimer: Timer?
            @State var bottomPressedTimer: Timer?
            
            var body: some View {
                ZStack {
                    Color.black.opacity(0.5)
                    VStack(spacing: 0) {
                        Color.white.opacity(topPressed ? 0.5 : 0.0001)
                            .onLongPressGesture(minimumDuration: 0) {
                                damageTaken += 1
                                lifePoints -= 1
                                
                                topPressed = true
                                topPressedTimer?.invalidate()
                                topPressedTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { timer in
                                    topPressed = false
                                }
                            }
                        
                        Color.white.opacity(bottomPressed ? 0.5 : 0.0001)
                            .onLongPressGesture(minimumDuration: 0) {
                                if damageTaken > 0 {
                                    damageTaken -= 1
                                    lifePoints += 1
                                    
                                    bottomPressed = true
                                    bottomPressedTimer?.invalidate()
                                    bottomPressedTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { timer in
                                        bottomPressed = false
                                    }
                                }
                            }
                    }
                    Text("\(damageTaken)")
                        .font(UIDevice.isIPhone ? .title : .largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }
        }
        
        struct CounterView: View {
            let title: String
            let imageName: String
            @Binding var value: Int
            
            var body: some View {
                ZStack {
                    Counter(title: title, imageName: imageName, value: $value)
                        .onTapGesture {
                            value += 1
                        }
                        .onLongPressGesture(minimumDuration: 0.1) {
                            value = 0
                        }
                }
            }
            
            struct Counter: View {
                let blurEffect: UIBlurEffect.Style = .systemThinMaterialDark
                let title: String
                let imageName: String
                @Binding var value: Int
                
                var body: some View {
                    ZStack {
                        VisualEffectView(effect: UIBlurEffect(style: blurEffect))
                        
                        ZStack {
                            Image(imageName)
                                .resizable()
                                .scaledToFit()
                                .opacity(0.2)
                            
                            VStack(spacing: 5) {
                                Text(title)
                                    .headline()
                                
                                Text("\(value)")
                                    .title()
                            }
                        }.padding(5)
                    }.frame(maxWidth: 80).cornerRadius(10)
                }
            }
        }
    }
}
