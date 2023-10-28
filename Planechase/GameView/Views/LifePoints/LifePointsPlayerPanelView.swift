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
    @State var showProfileSelector: Bool = false
    @State var showTreacheryPanel: Bool = false
    var isPlayerOnTheSide: Bool {
        playerId == 0 && lifePointsViewModel.numberOfPlayer % 2 == 1
    }
    var isPlayerOnOppositeSide: Bool {
        (playerId < lifePointsViewModel.numberOfPlayer / 2 + lifePointsViewModel.numberOfPlayer % 2) && (!isPlayerOnTheSide)
    }
    @State var profileChangeTimerProgress: CGFloat = 1
    @Binding var isAllowedToChangeProfile: Bool
    
    var body: some View {
        ZStack {
            CountersSheet(showSheet: $showingCountersSheet, playerCounters: $player.counters, lifePoints: $player.lifePoints, playerId: playerId)
                .cornerRadius(isMiniView ? 0 : 15).padding(isMiniView ? 0 : (UIDevice.isIPhone ? 2 : 10))
                .allowsHitTesting(showingCountersSheet)
                .opacity(showingCountersSheet ? 1 : 0)

            ZStack(alignment: .bottom) {
                // BACKGROUND
                if let image = player.backgroundImage {
                    ZStack {
                        GeometryReader { geo in
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .clipped()
                        }
                        Color.black.opacity(0.15)
                    }
                } else {
                    if planechaseVM.lifeCounterOptions.colorPaletteId == -1 {
                        VisualEffectView(effect: UIBlurEffect(style: blurEffect))
                    } else {
                        if let style = planechaseVM.lifeCounterOptions.backgroundStyleId, style >= 0 {
                            GeometryReader { geo in
                                CustomBackgroundStyle.getSelectedBackgroundImage(style)
                                    .resizable()
                                    .scaledToFill()
                                    .colorMultiply(players[playerId].backgroundColor)
                                    .clipped()
                            }
                        } else {
                            players[playerId].backgroundColor
                        }
                    }
                }
                
                if true && !isMiniView {
                    TreacheryCardView(player: $player, putCardOnTheRight: isPlayerOnOppositeSide)
                }
                
                if planechaseVM.lifeCounterOptions.useCommanderDamages && !isMiniView {
                    HStack(alignment: .center) {
                        Spacer()
                        CounterRecapView(value: player.counters.poison, imageName: "Poison", size: 70)
                        Color.white.frame(width: UIDevice.isIPhone ? 55 : 80).opacity(0)
                        CounterRecapView(value: player.counters.commanderTax, imageName: "CommanderTax", size: 60)
                        Spacer()
                    }.offset(y: -15)
                }
                LifePointsPanelView(playerName: player.name, lifepoints: $player.lifePoints, totalChange: $totalChange, isMiniView: isMiniView, inverseChangeSide: isPlayerOnOppositeSide || isPlayerOnTheSide).cornerRadius(15)
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
                
                if !isMiniView {
                    GeometryReader { geo in
                        HStack {
                            if isPlayerOnOppositeSide {
                                Spacer()
                            }
                            Button(action: {
                                showTreacheryPanel = true
                                lifepointHasBeenUsedToggler.toggle()
                            }, label: {
                                Color.black
                                    .frame(width: CardSizes.classic_widthForHeight(geo.size.height ) - (geo.size.height / 4))
                                    .opacity(0.000001)
                            })
                            if !isPlayerOnOppositeSide {
                                Spacer()
                            }
                        }
                    }
                }
                
                if planechaseVM.lifeCounterOptions.useCommanderDamages && !isMiniView {
                    CommanderRecapView(playerId: playerId, lifePoints: $player.lifePoints, playerCounters: $player.counters)
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showingCountersSheet = true
                            }
                            lifepointHasBeenUsedToggler.toggle()
                        }.offset(y: -20)
                }
                
                if !isMiniView && planechaseVM.lifeCounterProfiles.count > 0 {
                    GeometryReader { geo in
                        VStack  {
                            Button(action: {
                                showProfileSelector = true
                                lifepointHasBeenUsedToggler.toggle()
                            }, label: {
                                ZStack(alignment: .top) {
                                    Color.black.opacity(0.000001).frame(width: 100, height: 80)
                                    ZStack {
                                        Image(systemName: "pencil")
                                            .font(.title)
                                            .foregroundColor(.white)
                                        Circle()
                                            .stroke(
                                                Color.white,
                                                style: StrokeStyle(
                                                    lineWidth: 4,
                                                    lineCap: .round
                                                )
                                            )
                                    }.frame(width: 45, height: 45).padding(8)
                                }
                            }).iPhoneScaler(width: 100, height: 80, scaleEffect: 0.6, anchor: .top)
                            Spacer()
                        }.frame(maxWidth: .infinity)
                    }.opacity(isAllowedToChangeProfile ? 1 : 0)
                }
                if showProfileSelector {
                    ProfileSelector(showSelector: $showProfileSelector, playerId: playerId, player: $player, lifepointHasBeenUsedToggler: $lifepointHasBeenUsedToggler)
                }
                if showTreacheryPanel {
                    TreacheryPanelView(treacheryData: $player.treachery, showPanel: $showTreacheryPanel, lifepointHasBeenUsedToggler: $lifepointHasBeenUsedToggler, isOnTheOppositeSide: isPlayerOnOppositeSide)
                }
                
            }.cornerRadius(isMiniView ? 0 : 15).padding(isMiniView ? 0 : (UIDevice.isIPhone ? 2 : 10))
                .gesture(DragGesture()
                    .onChanged { value in
                        if !showTreacheryPanel {
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
                        if !showTreacheryPanel {
                            startTotalChangeTimer()
                        }
                    })
                )
                .allowsHitTesting(!showingCountersSheet)
                .opacity(!showingCountersSheet ? 1 : 0)
            
            Color.white.opacity(hasBeenChoosenRandomly ? 1 : 0).cornerRadius(isMiniView ? 0 : 15).padding(isMiniView ? 0 : (UIDevice.isIPhone ? 2 : 10)).allowsHitTesting(false)
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
        let imageName: String
        let size: CGFloat
        
        var body: some View {
            ZStack {
                Image(imageName)
                    .resizable()
                    .frame(width: size, height: size)
                    .foregroundColor(Color.white)
                    .opacity(0.2)
                
                Text("\(value)")
                    .title()
            }.opacity(value > 0 ? 1 : 0)
        }
    }
    
    struct ProfileSelector: View {
        @EnvironmentObject var lifePointsViewModel: LifePointsViewModel
        @EnvironmentObject var planechaseVM: PlanechaseViewModel
        @Binding var showSelector: Bool
        let playerId: Int
        @Binding var player: PlayerProfile
        @Binding var lifepointHasBeenUsedToggler: Bool
        var body: some View {
            VStack {
                ScrollView(.vertical) {
                    VStack {
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                player.backgroundImage = nil
                                player.id = UUID()
                                player.name = "\("lifepoints_player".translate()) \(playerId + 1)"
                                
                                showSelector = false
                            }
                            lifepointHasBeenUsedToggler.toggle()
                            cancelLastUsedSlot(slot: playerId)
                            planechaseVM.saveProfiles_Info()
                        }, label: {
                            Text("lifepoints_noProfile".translate())
                                .textButtonLabel()
                        }).padding(.top, 5)
                        ForEach(0..<planechaseVM.lifeCounterProfiles.count, id: \.self) { i in
                            if let profile = planechaseVM.lifeCounterProfiles[i] {
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        var backgroundImage: UIImage? = nil
                                        if let imageData = profile.customImageData {
                                            if let image = UIImage(data: imageData) {
                                                backgroundImage = image
                                            }
                                        }
                                        
                                        player.backgroundImage = backgroundImage
                                        player.id = profile.id
                                        player.name = profile.name
                                        
                                        showSelector = false
                                    }
                                    lifepointHasBeenUsedToggler.toggle()
                                    cancelLastUsedSlot(slot: playerId)
                                    planechaseVM.lifeCounterProfiles[i].lastUsedSlot = playerId
                                    planechaseVM.saveProfiles_Info()
                                }, label: {
                                    Text(profile.name)
                                        .textButtonLabel(style: player.id == profile.id ? .secondary : .primary)
                                })
                            }
                        }
                    }.frame(maxWidth: .infinity)
                }
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showSelector = false
                    }
                }, label: {
                    ZStack {
                        LinearGradient(colors: [Color.black.opacity(0.8), Color.black.opacity(0)], startPoint: .bottom, endPoint: .top)
                        Text("cancel".translate())
                            .font(.title)
                            .foregroundColor(.white)
                    }.frame(height: 50)
                })
            }.background(VisualEffectView(effect: UIBlurEffect(style: UIBlurEffect.Style.systemMaterialDark)))
        }
        
        func cancelLastUsedSlot(slot: Int) {
            for i in 0..<planechaseVM.lifeCounterProfiles.count {
                if planechaseVM.lifeCounterProfiles[i].lastUsedSlot == slot {
                    planechaseVM.lifeCounterProfiles[i].lastUsedSlot = -1
                }
            }
            for i in 0..<lifePointsViewModel.players.count {
                if lifePointsViewModel.players[i].id == player.id && i != slot {
                    print("Found at \(i) for \(slot)")
                    withAnimation(.easeInOut(duration: 0.3)) {
                        lifePointsViewModel.players[i].backgroundImage = nil
                        lifePointsViewModel.players[i].id = UUID()
                        lifePointsViewModel.players[i].name = "\("lifepoints_player".translate()) \(i + 1)"
                    }
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
                    // iPhone scaling THIS IS UGLY AS FUCK
                    .offset(y: UIDevice.isIPhone ? (isPlayerOnTheSide ? -60 : 0) : (isPlayerOnTheSide ? 20 : 0))
                    .offset(x: isPlayerOnTheSide ? (UIDevice.isIPhone ? 110 : 10) : 0)
                    .scaleEffect(UIDevice.isIPhone ? 0.6 : 1, anchor: .bottom)
                    
                    if !isPlayerOnTheSide {
                        Spacer()
                    }
                }.frame(maxHeight: .infinity, alignment: isPlayerOnTheSide ? .center : .bottom)                 .padding(.vertical, 0)
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
