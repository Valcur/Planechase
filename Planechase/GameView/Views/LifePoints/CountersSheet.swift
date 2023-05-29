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
        @Binding var showSheet: Bool
        @Binding var playerCounters: PlayerCounters
        @Binding var lifePoints: Int
        let playerId: Int
        
        var body: some View {
            ZStack(alignment: .top) {
                Color.black.opacity(0.3)
                ScrollView(.vertical) {
                    if playerId == 0 && lifePointsViewModel.numberOfPlayer % 2 == 1 {
                        HStack(spacing: 20) {
                            CountersVStack(playerCounters: $playerCounters)
                            
                            CommanderVStack(playerCounters: $playerCounters, lifePoints: $lifePoints, playerId: playerId)
                        }.padding(5)
                    } else {
                        VStack(spacing: 0) {
                            CountersVStack(playerCounters: $playerCounters)
                            
                            CommanderVStack(playerCounters: $playerCounters, lifePoints: $lifePoints, playerId: playerId)
                            
                            Spacer()
                        }.padding(5)
                    }
                }
                Button(action: {
                    showSheet = false
                }, label: {
                    Text("exit".translate())
                        .textButtonLabel()
                })
            }.ignoresSafeArea()
        }
        
        struct CountersVStack: View {
            @Binding var playerCounters: PlayerCounters
            var body: some View {
                VStack(alignment: .leading, spacing: UIDevice.isIPhone ? 3 : 15) {
                    if !UIDevice.isIPhone {
                        Text("lifepoints_counters_title".translate())
                            .headline()
                    }
                    
                    HStack {
                        CounterView(title: "lifepoints_counters_poison".translate(), imageName: "Poison", value: $playerCounters.poison)
                        
                        Spacer()
                        
                        CounterView(title: "lifepoints_counters_tax".translate(), imageName: "CommanderTax", value: $playerCounters.commanderTax)
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
            
            
            var body: some View {
                VStack(alignment: .leading, spacing: UIDevice.isIPhone ? 3 : 15) {
                    Text("lifepoints_commander_title".translate())
                        .headline()
                    
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
                    }.frame(height: UIDevice.isIPhone ? 110 : 150)
                }
            }
        }
        
        struct CommanderDamage: View {
            let blurEffect: UIBlurEffect.Style = .systemThinMaterialDark
            @Binding var damageTaken: Int
            @Binding var lifePoints: Int
            
            var body: some View {
                Button(action: {
                    damageTaken += 1
                    lifePoints -= 1
                }, label: {
                    ZStack {
                        VisualEffectView(effect: UIBlurEffect(style: blurEffect))
                        Text("\(damageTaken)")
                            .font(.title2)
                            .foregroundColor(.white)
                    }.cornerRadius(10).padding(3)
                })
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
                    }.frame(width: 80).cornerRadius(10)
                }
            }
            
            struct MinusButton: View {
                @Binding var value: Int
                
                var body: some View {
                    Button(action: {
                        if value > 0 {
                            value -= 1
                        }
                    }, label: {
                        Image(systemName: "minus.circle")
                            .resizable()
                            .frame(width: 30, height: 30)
                    })
                }
            }
            
            struct PlusButton: View {
                @Binding var value: Int
                
                var body: some View {
                    Button(action: {
                        value += 1
                    }, label: {
                        Image(systemName: "plus.circle")
                            .resizable()
                            .frame(width: 30, height: 30)
                    })
                }
            }
        }
    }
}
