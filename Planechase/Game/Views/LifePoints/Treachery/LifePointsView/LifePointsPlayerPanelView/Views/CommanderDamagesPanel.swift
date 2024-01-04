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
        
        var body: some View {
            ZStack {
                if !isFullscreen && playerId == 0 && lifePointsViewModel.numberOfPlayer % 2 == 1 {
                    HStack(spacing: 20) {
                        Spacer()
                        VStack {
                            Spacer()
                            Text("Tap to increase, Hold to reset").headline()
                            Spacer()
                            PartnerSwitch(playerId: playerId)
                            Spacer()
                        }
                        Spacer()
                        CommanderVStack(playerCounters: $playerCounters, lifePoints: $lifePoints, playerId: playerId, isFullscreen: isFullscreen)
                            .frame(maxWidth: UIDevice.isIPhone ? .infinity : 200)
                        Spacer()
                    }.padding(5)
                } else {
                    VStack(spacing: UIDevice.isIPhone ? 0 : 20) {
                        Text("Tap to increase, Hold to reset").headline()
                        CommanderVStack(playerCounters: $playerCounters, lifePoints: $lifePoints, playerId: playerId, isFullscreen: isFullscreen)
                        Spacer()
                        PartnerSwitch(playerId: playerId)
                    }.padding(5).padding(.vertical, UIDevice.isIPhone ? 5 : 20)
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
                    ZStack {
                        if lifePointsViewModel.numberOfPlayer % 2 == 0 {
                            EvenBlueprint(row1: AnyView(HStack(spacing: 0) {
                                ForEach(1...halfNumberOfPlayers, id: \.self) { i in
                                    CommanderDamage(damageTaken: $playerCounters.commanderDamages[i - 1],
                                                    lifePoints: $lifePoints,
                                                    isFullscreen: isFullscreen)
                                        .commanderDamageToYourself(i - 1 == playerId)
                                }
                            }), row2: AnyView(HStack(spacing: 0) {
                                ForEach(1...halfNumberOfPlayers, id: \.self) { i in
                                    CommanderDamage(damageTaken: $playerCounters.commanderDamages[i + halfNumberOfPlayers - 1],
                                                    lifePoints: $lifePoints,
                                                    isFullscreen: isFullscreen)
                                        .commanderDamageToYourself(i + halfNumberOfPlayers - 1 == playerId)
                                }
                            }))
                        } else {
                            UnevenBlueprint(row1: AnyView(HStack(spacing: 0) {
                                ForEach(1...halfNumberOfPlayers, id: \.self) { i in
                                    CommanderDamage(damageTaken: $playerCounters.commanderDamages[i],
                                                    lifePoints: $lifePoints,
                                                    isFullscreen: isFullscreen)
                                        .commanderDamageToYourself(i == playerId)
                                }
                            }),
                                            row2: AnyView(                    HStack(spacing: 0) {
                                ForEach(1...halfNumberOfPlayers, id: \.self) { i in
                                    CommanderDamage(damageTaken: $playerCounters.commanderDamages[i + halfNumberOfPlayers],
                                                    lifePoints: $lifePoints,
                                                    isFullscreen: isFullscreen)
                                        .commanderDamageToYourself(i + halfNumberOfPlayers == playerId)
                                }
                            }),
                                            sideElement: AnyView(CommanderDamage(damageTaken: $playerCounters.commanderDamages[0],
                                                                                 lifePoints: $lifePoints,
                                                                                 isFullscreen: isFullscreen)
                                                .commanderDamageToYourself(0 == playerId))
                            )
                        }
                    }
                    .frame(width: rotationAngle == 90 ? (isFullscreen ? (UIDevice.isIPhone ? geo.size.width * 1.3 : geo.size.width - 115) : geo.size.height) : geo.size.width)
                    .frame(maxHeight: isFullscreen ? geo.size.height : (UIDevice.isIPhone ? 100 : 200))
                    .rotationEffect(.degrees(rotationAngle), anchor: rotationAngle == 90 && !isFullscreen ? .topTrailing : .center)
                    .offset(y: rotationAngle == 90 && !isFullscreen ? geo.size.height : 0)
                    .frame(width: !isFullscreen && rotationAngle == 90 ? (UIDevice.isIPhone ? 100 : 200) : geo.size.width)
                }.padding(.vertical, isFullscreen ? (rotationAngle == 90 ? 115 : 10) : 0)
            }
        }
        
        struct CommanderDamage: View {
            let blurEffect: UIBlurEffect.Style = .systemThinMaterialDark
            @Binding var damageTaken: [Int]
            @Binding var lifePoints: Int
            let isFullscreen: Bool
            
            var body: some View {
                HStack(spacing: 2) {
                    ForEach(0..<damageTaken.count, id: \.self) { i in
                        ZStack {
                            VisualEffectView(effect: UIBlurEffect(style: blurEffect))
                            if isFullscreen {
                                Text("\(damageTaken[i])")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            } else {
                                Text("\(damageTaken[i])")
                                    .font(.title2)
                                    .foregroundColor(.white)
                            }
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
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.white, lineWidth: 1)
                )
                .padding(3)
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
