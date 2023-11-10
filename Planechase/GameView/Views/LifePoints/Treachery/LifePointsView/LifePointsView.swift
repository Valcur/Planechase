//
//  LifePointsView.swift
//  Planechase
//
//  Created by Loic D on 30/04/2023.
//

import SwiftUI

struct LifePointsView: View {
    @EnvironmentObject var planechaseVM: PlanechaseViewModel
    @EnvironmentObject var gameVM: GameViewModel
    @EnvironmentObject var lifePointsViewModel: LifePointsViewModel
    var halfNumberOfPlayers: Int {
        lifePointsViewModel.numberOfPlayer / 2
    }
    let isMiniView: Bool
    @State var playersChoosenRandomly: [Bool]
    @State var hideLifeTimer: Timer?
    @State var hideLifeTimerToggler: Bool = true
    @State var showMonarchToken = false
    @State var isAllowedToChangeProfile: Bool = false
    
    init(isMiniView: Bool = false) {
        self.isMiniView = isMiniView
        playersChoosenRandomly = Array(repeating: false, count: 8)
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                HStack {
                    if !isMiniView {
                        VStack(alignment: .leading) {
                            CircularButtonView(buttons: [
                                AnyView(
                                    Button(action: {
                                        resetTimer()
                                        let player = Int.random(in: 0..<lifePointsViewModel.numberOfPlayer)
                                        playersChoosenRandomly[player] = true
                                        withAnimation(.easeInOut(duration: 1).delay(0.15)) {
                                            playersChoosenRandomly[player] = false
                                        }
                                    }, label: {
                                        Image(systemName: "questionmark.square")
                                            .imageButtonLabel(style: .noBackground)
                                    })
                                ),
                                
                                AnyView(
                                    Button(action: {
                                        resetTimer()
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            showMonarchToken.toggle()
                                        }
                                    }, label: {
                                        Image("Crown 1")
                                            .imageButtonLabel(style: .noBackground)
                                            .opacity(showMonarchToken ? 0.7 : 1)
                                    }).opacity(planechaseVM.lifeCounterOptions.useMonarchToken ? 1 : 0)
                                ),

                                AnyView(
                                    Button(action: {
                                        resetTimer()
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            isAllowedToChangeProfile.toggle()
                                        }
                                        if isAllowedToChangeProfile == false {
                                            SaveManager.saveLastUsedSetup(lifePointsViewModel.lastUsedSetup)
                                        }
                                    }, label: {
                                        Image(systemName: "pencil")
                                            .imageButtonLabel(style: .noBackground)
                                            .opacity(isAllowedToChangeProfile ? 0.7 : 1)
                                    })
                                )
                            ], lifepointHasBeenUsedToggler: $hideLifeTimerToggler)
                            
                            Spacer()
                            
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    gameVM.showLifePointsView.toggle()
                                }
                            }, label: {
                                Image(systemName: "xmark")
                                    .imageButtonLabel(style: .noBackground)
                                    .frame(height: 100)
                            }).frame(height: 40).offset(x: UIDevice.isIPhone ? 10 : 0, y: 0)
                        }
                    }
                    
                    ZStack {
                        if lifePointsViewModel.numberOfPlayer % 2 == 0 {
                            EvenBlueprint(row1:
                                            AnyView(HStack(spacing: 0) {
                                ForEach(1...halfNumberOfPlayers, id: \.self) { i in
                                    LifePointsPlayerPanelView(playerId: i - 1, player: $lifePointsViewModel.players[i - 1], isMiniView: isMiniView, hasBeenChoosenRandomly: playersChoosenRandomly[i - 1], lifepointHasBeenUsedToggler: $hideLifeTimerToggler, isAllowedToChangeProfile: $isAllowedToChangeProfile, showMonarchToken: $showMonarchToken)
                                }
                            }), row2:
                                            AnyView(HStack(spacing: 0) {
                                ForEach(1...halfNumberOfPlayers, id: \.self) { i in
                                    LifePointsPlayerPanelView(playerId: i + halfNumberOfPlayers - 1, player: $lifePointsViewModel.players[i + halfNumberOfPlayers - 1], isMiniView: isMiniView, hasBeenChoosenRandomly: playersChoosenRandomly[i + halfNumberOfPlayers - 1], lifepointHasBeenUsedToggler: $hideLifeTimerToggler, isAllowedToChangeProfile: $isAllowedToChangeProfile, showMonarchToken: $showMonarchToken)
                                }
                            }))
                        } else {
                            UnevenBlueprint(row1: AnyView(HStack(spacing: 0) {
                                ForEach(1...halfNumberOfPlayers, id: \.self) { i in
                                    LifePointsPlayerPanelView(playerId: i, player: $lifePointsViewModel.players[i], isMiniView: isMiniView, hasBeenChoosenRandomly: playersChoosenRandomly[i], lifepointHasBeenUsedToggler: $hideLifeTimerToggler, isAllowedToChangeProfile: $isAllowedToChangeProfile, showMonarchToken: $showMonarchToken)
                                }
                            }),
                                            row2: AnyView(                    HStack(spacing: 0) {
                                ForEach(1...halfNumberOfPlayers, id: \.self) { i in
                                    LifePointsPlayerPanelView(playerId: i + halfNumberOfPlayers, player: $lifePointsViewModel.players[i + halfNumberOfPlayers], isMiniView: isMiniView, hasBeenChoosenRandomly: playersChoosenRandomly[i + halfNumberOfPlayers], lifepointHasBeenUsedToggler: $hideLifeTimerToggler, isAllowedToChangeProfile: $isAllowedToChangeProfile, showMonarchToken: $showMonarchToken)
                                }
                            }),
                                            sideElement: AnyView(LifePointsPlayerPanelView(playerId: 0, player: $lifePointsViewModel.players[0], isMiniView: isMiniView, hasBeenChoosenRandomly: playersChoosenRandomly[0], lifepointHasBeenUsedToggler: $hideLifeTimerToggler, isAllowedToChangeProfile: $isAllowedToChangeProfile, showMonarchToken: $showMonarchToken))
                            )
                        }
                        if !isMiniView {
                            MonarchTokenView(lifepointHasBeenUsedToggler: $hideLifeTimerToggler).opacity(showMonarchToken ? 1 : 0)
                        }
                    }.clipped()
                }
            }.frame(width: geo.size.width, height: geo.size.height)
                .background(
                    Color.black.opacity(isMiniView ? 0 : 1)
                    //VisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark)).opacity(isMiniView ? 0 : 1)
                )
        }.ignoresSafeArea()
        .onChange(of: gameVM.showLifePointsView) { isShowing in
            if !isMiniView {
                if isShowing {
                    resetTimer()
                } else {
                    hideLifeTimer?.invalidate()
                }
            }
        }
        
        .onChange(of: hideLifeTimerToggler) { _ in
            resetTimer()
        }
    }
    
    private func resetTimer() {
        print("Reset")
        let timer = planechaseVM.lifeCounterOptions.autoHideLifepointsCooldown
        if timer == -1 {
            return
        }
        hideLifeTimer?.invalidate()
        hideLifeTimer = Timer.scheduledTimer(withTimeInterval: timer, repeats: false) { timer in
            withAnimation(.easeInOut(duration: 0.3)) {
                gameVM.showLifePointsView = false
            }
        }
    }
}

extension View {
    func commanderDamageToYourself(_ isYourself: Bool) -> some View {
        self.opacity(isYourself ? 0.4 : 1)
    }
}
