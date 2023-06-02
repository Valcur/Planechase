//
//  CountersSheet.swift
//  Planechase
//
//  Created by Loic D on 25/05/2023.
//

import SwiftUI

extension LifePointsPlayerPanelView {
    struct CountersSheet: View {
        @EnvironmentObject var lifePointsViewModel: LifePointsViewModel
        var halfNumberOfPlayers: Int {
            lifePointsViewModel.numberOfPlayer / 2
        }
        @State var exitTimer: Timer?
        @Binding var showSheet: Bool
        @Binding var playerCounters: PlayerCounters
        @Binding var lifePoints: Int
        let playerId: Int
        
        var body: some View {
            ZStack(alignment: .top) {
                Color.black.opacity(0.3)
                ScrollView(.vertical) {
                    ScrollViewReader { reader in
                        VStack {
                            if playerId == 0 && lifePointsViewModel.numberOfPlayer % 2 == 1 {
                                HStack(spacing: 20) {
                                    CountersVStack(playerCounters: $playerCounters)
                                    
                                    CommanderVStack(playerCounters: $playerCounters, lifePoints: $lifePoints, playerId: playerId)
                                }.padding(5).padding(.top, lifePointsViewModel.numberOfPlayer == 3 || !UIDevice.isIPhone ? 20 : 5)
                            } else {
                                VStack(spacing: UIDevice.isIPhone ? 0 : 20) {
                                    CountersVStack(playerCounters: $playerCounters)
                                    
                                    CommanderVStack(playerCounters: $playerCounters, lifePoints: $lifePoints, playerId: playerId)
                                    
                                    Spacer()
                                }.padding(5).padding(.vertical, UIDevice.isIPhone ? 5 : 20)
                            }
                        }.padding(.bottom, 75).id(0)
                        .onChange(of: showSheet) { _ in
                            if showSheet {
                                exitTimer?.invalidate()
                                startExitTimer()
                                reader.scrollTo(0, anchor: .top)
                            }
                        }
                    }
                }
                .onChange(of: playerCounters.poison) { _ in
                    exitTimer?.invalidate()
                    startExitTimer()
                }
                .onChange(of: playerCounters.commanderTax) { _ in
                    exitTimer?.invalidate()
                    startExitTimer()
                }
                .onChange(of: playerCounters.commanderDamages) { _ in
                    exitTimer?.invalidate()
                    startExitTimer()
                }
            }.ignoresSafeArea()
        }
        
        private func startExitTimer() {
            exitTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { timer in
                withAnimation(.easeInOut(duration: 0.3)) {
                    showSheet = false
                }
            }
        }
        
        struct CountersVStack: View {
            @Binding var playerCounters: PlayerCounters
            var body: some View {
                VStack(alignment: .leading, spacing: UIDevice.isIPhone ? 3 : 15) {
                    /*if !UIDevice.isIPhone {
                        Text("lifepoints_counters_title".translate())
                            .headline()
                    }*/
                    
                    HStack {
                        Spacer()
                        CounterView(title: "lifepoints_counters_poison".translate(), imageName: "Poison", value: $playerCounters.poison)
                        
                        Spacer()
                        
                        CounterView(title: "lifepoints_counters_tax".translate(), imageName: "CommanderTax", value: $playerCounters.commanderTax)
                        Spacer()
                    }.padding(.horizontal, UIDevice.isIPhone ? 0 : 15)
                }
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
                VStack(alignment: .leading, spacing: UIDevice.isIPhone ? 3 : 15) {
                    /*Text("lifepoints_commander_title".translate())
                        .headline()*/
                    
                    ZStack {
                        if lifePointsViewModel.numberOfPlayer % 2 == 0 {
                            EvenBlueprint(row1: AnyView(HStack(spacing: 0) {
                                ForEach(1...halfNumberOfPlayers, id: \.self) { i in
                                    CommanderDamage(damageTaken: $playerCounters.commanderDamages[i - 1], lifePoints: $lifePoints)
                                        .commanderDamageToYourself(i - 1 == playerId)
                                }
                            }), row2: AnyView(HStack(spacing: 0) {
                                ForEach(1...halfNumberOfPlayers, id: \.self) { i in
                                    CommanderDamage(damageTaken: $playerCounters.commanderDamages[i + halfNumberOfPlayers - 1], lifePoints: $lifePoints)
                                        .commanderDamageToYourself(i + halfNumberOfPlayers - 1 == playerId)
                                }
                            }))
                        } else {
                            UnevenBlueprint(row1: AnyView(HStack(spacing: 0) {
                                ForEach(1...halfNumberOfPlayers, id: \.self) { i in
                                    CommanderDamage(damageTaken: $playerCounters.commanderDamages[i], lifePoints: $lifePoints)
                                        .commanderDamageToYourself(i == playerId)
                                }
                            }),
                                            row2: AnyView(                    HStack(spacing: 0) {
                                ForEach(1...halfNumberOfPlayers, id: \.self) { i in
                                    CommanderDamage(damageTaken: $playerCounters.commanderDamages[i + halfNumberOfPlayers], lifePoints: $lifePoints)
                                        .commanderDamageToYourself(i + halfNumberOfPlayers == playerId)
                                }
                            }),
                                            sideElement: AnyView(CommanderDamage(damageTaken: $playerCounters.commanderDamages[0], lifePoints: $lifePoints)
                                                .commanderDamageToYourself(0 == playerId))
                            )
                        }
                    }
                    .rotationEffect(.degrees(rotationAngle))
                    // OMG WHAT THE FUCK
                    .frame(height: UIDevice.isIPhone ? (rotationAngle == 90 ? 110 : 90) : 150)
                    .frame(maxWidth: rotationAngle == 90 ? (UIDevice.isIPhone ? (lifePointsViewModel.numberOfPlayer == 3 ? 250 : 150) : 230) : 300)
                    .offset(y: rotationAngle == 90 ? 25 : 0)
                }
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
                }.cornerRadius(10).padding(3)
                .onTapGesture {
                    damageTaken += 1
                    lifePoints -= 1
                }
                .onLongPressGesture(minimumDuration: 0.1) {
                    lifePoints += damageTaken
                    damageTaken = 0
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