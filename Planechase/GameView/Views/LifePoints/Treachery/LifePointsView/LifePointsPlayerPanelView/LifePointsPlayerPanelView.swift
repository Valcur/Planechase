//
//  LifePointsPlayerPanelView.swift
//  Planechase
//
//  Created by Loic D on 30/05/2023.
//

import SwiftUI

struct LifePointsPlayerPanelView: View {
    @EnvironmentObject var planechaseVM: PlanechaseViewModel
    @EnvironmentObject var lifePointsViewModel: LifePointsViewModel
    let playerId: Int
    var players: [PlayerProfile] {
        lifePointsViewModel.players
    }
    @Binding var player: PlayerProfile
    @State var prevValue: CGFloat = 0
    @State var totalChange: Int = 0
    @State var totalChangeTimer: Timer?
    let blurEffect: UIBlurEffect.Style = .systemChromeMaterialDark
    let isMiniView: Bool
    let hasBeenChoosenRandomly: Bool
    @Binding var lifepointHasBeenUsedToggler: Bool
    @State private var showingCountersSheet = false
    @State var showTreacheryPanel: Bool = false
    @State var showAlternativeCounters: Bool = false
    var isPlayerOnTheSide: Bool {
        playerId == 0 && lifePointsViewModel.numberOfPlayer % 2 == 1
    }
    var isPlayerOnOppositeSide: Bool {
        (playerId < lifePointsViewModel.numberOfPlayer / 2 + lifePointsViewModel.numberOfPlayer % 2) && (!isPlayerOnTheSide)
    }
    var isInAPanel: Bool {
        return showingCountersSheet || showTreacheryPanel || showAlternativeCounters || isAllowedToChangeProfile
    }
    @Binding var isAllowedToChangeProfile: Bool
    @Binding var showMonarchToken: Bool
    
    var body: some View {
        ZStack(alignment: .bottom) {
            LifePointsPanelBackground(player: $player, isMiniView: isMiniView, isPlayerOnOppositeSide: isPlayerOnOppositeSide)
            
            LifePointsPanelView(playerName: player.name, lifepoints: $player.lifePoints, totalChange: $totalChange, isMiniView: isMiniView, inverseChangeSide: isPlayerOnOppositeSide || isPlayerOnTheSide, isPlayerOnSide: isPlayerOnTheSide)
                .cornerRadius(15)
            
            if !isMiniView {
                
                ZStack {
                    if planechaseVM.showPlusMinus {
                        HStack {
                            if !isPlayerOnOppositeSide {
                                Spacer()
                            }
                            VStack {
                                Spacer()
                                Image(systemName: "plus")
                                    .font(UIDevice.isIPhone ? .title3 : .title)
                                    .foregroundColor(.white)
                                    .opacity(0.5)
                                Spacer()
                                Spacer()
                                Image(systemName: "minus")
                                    .font(UIDevice.isIPhone ? .title3 : .title)
                                    .foregroundColor(.white)
                                    .opacity(0.5)
                                Spacer()
                            }
                            if isPlayerOnOppositeSide {
                                Spacer()
                            }
                        }.padding(15)
                    }
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
                }
                
                if planechaseVM.treacheryOptions.isTreacheryEnabled {
                    GeometryReader { geo in
                        HStack {
                            if isPlayerOnOppositeSide {
                                Spacer()
                            }
                            Color.black
                                .frame(width: CardSizes.classic_widthForHeight(geo.size.height ) - (geo.size.height / 3))
                                .opacity(0.00001)
                                .onTapGesture {
                                    showTreacheryPanel = true
                                    lifepointHasBeenUsedToggler.toggle()
                                }
                            if !isPlayerOnOppositeSide {
                                Spacer()
                            }
                        }
                    }
                }
                
                if planechaseVM.lifeCounterOptions.useCommanderDamages {
                    VStack {
                        HStack(alignment: .center, spacing: 0) {
                            ForEach(0..<player.counters.alternativeCounters.count, id: \.self) { i in
                                if let value = player.counters.alternativeCounters[i].value, value > 0 {
                                    CounterRecapView(value: value, counter: player.counters.alternativeCounters[i])
                                        .padding(4)
                                }
                            }
                        }
                        .background(VisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark)))
                        .cornerRadius(8)
                        .scaleEffect(UIDevice.isIPhone ? 0.65 : 1, anchor: .top)
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showAlternativeCounters = true
                            }
                            lifepointHasBeenUsedToggler.toggle()
                        }
                        Spacer()
                    }.padding(.top, UIDevice.isIPhone ? 4 : 8)
                    
                    if !showAlternativeCounters {
                        VStack {
                            Spacer()
                            Rectangle()
                                .foregroundColor(.black.opacity(0.00005))
                                .frame(width: 100, height: UIDevice.isIPhone ? 100 : 150)
                                .onTapGesture {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        showAlternativeCounters = true
                                    }
                                    lifepointHasBeenUsedToggler.toggle()
                                }
                            Spacer()
                        }
                    }
                    
                    CommanderRecapView(playerId: playerId, lifePoints: $player.lifePoints, playerCounters: $player.counters)
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showingCountersSheet = true
                            }
                            lifepointHasBeenUsedToggler.toggle()
                        }
                }
            
                Group {
                    if showAlternativeCounters {
                        AlternativeCountersView(counters: $player.counters.alternativeCounters, playerId: playerId, showAlternativeCounters: $showAlternativeCounters)
                    }
                    if isAllowedToChangeProfile {
                        ProfileSelector(playerId: playerId, player: $player, lifepointHasBeenUsedToggler: $lifepointHasBeenUsedToggler)
                    }
                    if showTreacheryPanel {
                        TreacheryPanelView(treacheryData: $player.treachery, showPanel: $showTreacheryPanel, lifepointHasBeenUsedToggler: $lifepointHasBeenUsedToggler, isOnTheOppositeSide: isPlayerOnOppositeSide)
                    }
                    if showingCountersSheet {
                        CommanderDamagesPanel(showSheet: $showingCountersSheet, playerCounters: $player.counters, lifePoints: $player.lifePoints, playerId: playerId)
                    }
                }
            }
            
            Color.black.opacity(player.lifePoints > 0 ? 0 : 0.7).allowsHitTesting(false)
            
            Color.clear.border(Color.white, width: 4)
                .opacity(lifePointsViewModel.currentMonarchId == playerId && !isInAPanel && showMonarchToken ? 1 : 0)
                .allowsHitTesting(false)
            
            Color.white.opacity(hasBeenChoosenRandomly ? 1 : 0).allowsHitTesting(false)
        }.cornerRadius(isMiniView ? 0 : 0)
            .padding(0)
            //.padding(.top, isMiniView ? 0 : 1)
            //.padding(.horizontal, isMiniView || isPlayerOnTheSide ? 0 : 1)
            .gesture(DragGesture()
                .onChanged { value in
                    if !isInAPanel {
                        let newValue = value.translation.height
                        if newValue > prevValue + 6 {
                            prevValue = newValue
                            removeLifepoint()
                        }
                        else if newValue < prevValue - 6 {
                            prevValue = newValue
                            addLifepoint()
                        }
                    }
                }
                .onEnded({ _ in
                    if !isInAPanel {
                        startTotalChangeTimer()
                    }
                })
            )
            .onChange(of: isInAPanel) { value in
                if lifePointsViewModel.currentMonarchId == playerId {
                    showMonarchToken = !value
                }
            }
    }
    
    private func addLifepoint() {
        totalChangeTimer?.invalidate()
        player.lifePoints += 1
        totalChange += 1
        lifepointHasBeenUsedToggler.toggle()
    }
    
    private func removeLifepoint() {
        totalChangeTimer?.invalidate()
        player.lifePoints -= 1
        totalChange -= 1
        lifepointHasBeenUsedToggler.toggle()
    }
    
    private func startTotalChangeTimer() {
        totalChangeTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { timer in
            totalChange = 0
        }
    }
    
    struct CounterRecapView: View {
        let value: Int
        let counter: AlternativeCounter
        let size: CGFloat = 40
        
        var body: some View {
            if true {
                ZStack(alignment: .bottomTrailing) {
                    Image(counter.imageName)
                        .resizable()
                        .frame(width: size, height: size)
                        .foregroundColor(Color.white)
                        .opacity(0.6)
                        .padding(.bottom, 20)
                    
                    Text("\(value)")
                        .foregroundColor(.white)
                        .font(.system(size: 25))
                        .fontWeight(.bold)
                }.padding(.horizontal, 2)
            } else {
                VStack(spacing: 0) {
                    Image(counter.imageName)
                        .resizable()
                        .frame(width: size, height: size)
                        .foregroundColor(Color.white)
                        .opacity(0.6)
                    
                    Text("\(value)")
                        .foregroundColor(.white)
                        .font(.system(size: 25))
                        .fontWeight(.bold)
                }
            }
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
        let playerId: Int
        @Binding var lifePoints: Int
        @Binding var playerCounters: PlayerCounters
        
        var body: some View {
            HStack {
                Spacer()
                VStack {
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
                    .frame(maxWidth: 200).frame(height: UIDevice.isIPhone ? 90 : 100)
                    .rotationEffect(.degrees(isPlayerOnTheSide ? 90 : (playerId < halfNumberOfPlayers + lifePointsViewModel.numberOfPlayer % 2 ? 180 : 0)))
                    //.frame(maxWidth: 200).frame(height: isPlayerOnTheSide ? 200 : (UIDevice.isIPhone ? 90 : 100))
                    .scaleEffect(UIDevice.isIPhone ? 0.65 : 1, anchor: isPlayerOnTheSide ? .trailing : .bottom)
                    .frame(maxWidth: 200).frame(height: isPlayerOnTheSide ? (UIDevice.isIPhone ? 130 : 200) : (UIDevice.isIPhone ? 90 : 100))
                    .padding(.trailing, isPlayerOnTheSide ? (UIDevice.isIPad ? 30 : 15) : 0)
                    
                    if isPlayerOnTheSide {
                        Spacer()
                    } else {
                        Spacer().frame(height: UIDevice.isIPhone ? 10 : 20)
                    }
                }
                
                if !isPlayerOnTheSide {
                    Spacer()
                }
            }
        }
        
        struct CommanderDamageRecapPanelView: View {
            let blurEffect: UIBlurEffect.Style = .systemThinMaterialDark
            @Binding var damageTaken: [Int]
            
            var body: some View {
                HStack(spacing: 2) {
                    ForEach(0..<damageTaken.count, id: \.self) { i in
                        ZStack {
                            VisualEffectView(effect: UIBlurEffect(style: blurEffect))
                            Text("\(damageTaken[i])")
                                .font(.title2)
                                .foregroundColor(.white)
                        }
                    }
                }.cornerRadius(10).padding(2)
            }
        }
    }
}
