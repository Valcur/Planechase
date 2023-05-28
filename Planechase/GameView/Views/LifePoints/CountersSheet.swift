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
        @Environment(\.presentationMode) var presentationMode
        var halfNumberOfPlayers: Int {
            lifePointsViewModel.numberOfPlayer / 2
        }
        var rotationAngle: Double {
            if lifePointsViewModel.numberOfPlayer % 2 == 1 {
                if playerId == 0 {
                    return -90
                } else if playerId <= halfNumberOfPlayers {
                    return 180
                } else {
                    return 0
                }
            } else {
                if playerId <= halfNumberOfPlayers {
                    return 180
                } else {
                    return 0
                }
            }
        }
        @Binding var playerCounters: PlayerCounters
        @Binding var lifePoints: Int
        let playerId: Int
        
        var body: some View {
            ZStack(alignment: .top) {
                Color.black
                ScrollView(.vertical) {
                    VStack(alignment: .leading, spacing: UIDevice.isIPhone ? 3 : 45) {
                        Text("lifepoints_counters_title".translate())
                            .title()
                            .padding(.top, UIDevice.isIPhone ? 0 : 30)
                        
                        HStack {
                            CounterView(title: "lifepoints_counters_poison".translate(), imageName: "Poison", rotationAngle: rotationAngle, value: $playerCounters.poison)
                            
                            Spacer()
                            
                            CounterView(title: "lifepoints_counters_tax".translate(), imageName: "CommanderTax", rotationAngle: rotationAngle, value: $playerCounters.commanderTax)
                        }.padding(.horizontal, 40)
                        
                        Text("lifepoints_commander_title".translate())
                            .title()
                        
                        ZStack {
                            if lifePointsViewModel.numberOfPlayer % 2 == 0 {
                                EvenBlueprint(row1: AnyView(HStack {
                                    ForEach(1...halfNumberOfPlayers, id: \.self) { i in
                                        CommanderDamage(damageTaken: $playerCounters.commanderDamages[i - 1], lifePoints: $lifePoints)
                                            .commanderDamageToYourself(i - 1 == playerId)
                                    }
                                }), row2: AnyView(HStack {
                                    ForEach(1...halfNumberOfPlayers, id: \.self) { i in
                                        CommanderDamage(damageTaken: $playerCounters.commanderDamages[i + halfNumberOfPlayers - 1], lifePoints: $lifePoints)
                                            .commanderDamageToYourself(i + halfNumberOfPlayers - 1 == playerId)
                                    }
                                }))
                            } else {
                                UnevenBlueprint(row1: AnyView(HStack {
                                    ForEach(1...halfNumberOfPlayers, id: \.self) { i in
                                        CommanderDamage(damageTaken: $playerCounters.commanderDamages[i], lifePoints: $lifePoints)
                                            .commanderDamageToYourself(i == playerId)
                                    }
                                }),
                                                row2: AnyView(                    HStack {
                                    ForEach(1...halfNumberOfPlayers, id: \.self) { i in
                                        CommanderDamage(damageTaken: $playerCounters.commanderDamages[i + halfNumberOfPlayers], lifePoints: $lifePoints)
                                            .commanderDamageToYourself(i + halfNumberOfPlayers == playerId)
                                    }
                                }),
                                                sideElement: AnyView(CommanderDamage(damageTaken: $playerCounters.commanderDamages[0], lifePoints: $lifePoints)
                                                    .commanderDamageToYourself(0 == playerId))
                                )
                            }
                        }.rotationEffect(.degrees(rotationAngle == 180 ? 180 : 0)).padding(.horizontal, 80).frame(height: 150).scaleEffect(UIDevice.isIPhone ? 0.8 : 1, anchor: .top)
                        
                        Spacer()
                    }.rotationEffect(.degrees(rotationAngle == 180 ? 180 : 0))
                }.padding(.vertical, 10).padding(.horizontal, 80)
                if UIDevice.isIPhone {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Text("exit".translate())
                            .textButtonLabel()
                    })
                }
            }.ignoresSafeArea()
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
                    }.cornerRadius(10).padding(5)
                })
            }
        }
        
        struct CounterView: View {
            let title: String
            let imageName: String
            let rotationAngle: Double
            @Binding var value: Int
            
            var body: some View {
                if rotationAngle == -90 {
                    VStack(spacing: 15) {
                        PlusButton(value: $value)
                        
                        Counter(title: title, imageName: imageName, value: $value)
                        
                        MinusButton(value: $value)
                    }.rotationEffect(.degrees(rotationAngle)).frame(height: 180)
                } else {
                    HStack(spacing: 15)  {
                        MinusButton(value: $value)
                        
                        Counter(title: title, imageName: imageName, value: $value)
                        
                        PlusButton(value: $value)
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
                        VStack(spacing: 5) {
                            Text(title)
                                .headline()
                            
                            Image(imageName)
                                .resizable()
                                .scaledToFit()
                                .padding(.horizontal, 15)
                            
                            Text("\(value)")
                                .title()
                        }.padding(5)
                    }.frame(width: 100).cornerRadius(10)
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
