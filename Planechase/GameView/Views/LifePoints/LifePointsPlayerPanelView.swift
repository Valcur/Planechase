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
    var isPlayerOnTheSide: Bool {
        playerId == 0 && lifePointsViewModel.numberOfPlayer % 2 == 1
    }
    
    var body: some View {
        ZStack {
            CountersSheet(showSheet: $showingCountersSheet, playerCounters: $player.counters, lifePoints: $player.lifePoints, playerId: playerId)
                .cornerRadius(isMiniView ? 0 : 15).padding(isMiniView ? 0 : (UIDevice.isIPhone ? 2 : 10))
                .allowsHitTesting(showingCountersSheet)
                .opacity(showingCountersSheet ? 1 : 0)

            ZStack(alignment: .bottom) {
                // BACKGROUND
                if let image = player.backgroundImage {
                    GeometryReader { geo in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: geo.size.width, height: geo.size.height)
                            .clipped()
                    }
                    
                } else {
                    if planechaseVM.lifeCounterOptions.colorPaletteId == -1 {
                        VisualEffectView(effect: UIBlurEffect(style: blurEffect))
                    } else {
                        GeometryReader { geo in
                            Image("PaperTexture")
                                .resizable()
                                .scaledToFill()
                                .colorMultiply(players[playerId].backgroundColor)
                                .frame(width: geo.size.width, height: geo.size.height)
                                .clipped()
                        }
                    }
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
                LifePointsPanelView(playerName: player.name, lifepoints: $player.lifePoints, totalChange: $totalChange, isMiniView: isMiniView, inverseChangeSide: playerId < lifePointsViewModel.numberOfPlayer / 2 + lifePointsViewModel.numberOfPlayer % 2).cornerRadius(15)
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
                    CommanderRecapView(playerId: playerId, lifePoints: $player.lifePoints, playerCounters: $player.counters)
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showingCountersSheet = true
                            }
                            lifepointHasBeenUsedToggler.toggle()
                        }.offset(y: -20)
                }
                
                if !isMiniView {
                    VStack {
                        Button(action: {
                            showProfileSelector = true
                            lifepointHasBeenUsedToggler.toggle()
                        }, label: {
                            Text("Change profile")
                                .textButtonLabel()
                        })
                        Spacer()
                    }.padding(5)
                }
                if showProfileSelector {
                    ProfileSelector(showSelector: $showProfileSelector, playerId: playerId, player: $player, lifepointHasBeenUsedToggler: $lifepointHasBeenUsedToggler)
                }
                
            }.cornerRadius(isMiniView ? 0 : 15).padding(isMiniView ? 0 : (UIDevice.isIPhone ? 2 : 10))
                .gesture(DragGesture()
                    .onChanged { value in
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
                    .onEnded({ _ in
                        startTotalChangeTimer()
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
        @EnvironmentObject var planechaseVM: PlanechaseViewModel
        @Binding var showSelector: Bool
        let playerId: Int
        @Binding var player: PlayerProfile
        @Binding var lifepointHasBeenUsedToggler: Bool
        var body: some View {
            ZStack(alignment: .topLeading) {
                VisualEffectView(effect: UIBlurEffect(style: UIBlurEffect.Style.systemMaterialDark))
                ScrollView(.vertical) {
                    VStack {
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                player.backgroundImage = nil
                                player.id = UUID()
                                player.name = "Player \(playerId + 1)" // Translate pls
                                
                                showSelector = false
                            }
                            lifepointHasBeenUsedToggler.toggle()
                            cancelLastUsedSlot(slot: playerId)
                            planechaseVM.saveProfiles_Info()
                        }, label: {
                            Text("No profile")
                                .textButtonLabel()
                        })
                        ForEach(0..<planechaseVM.lifeCounterProfiles.count, id: \.self) { i in
                            if let profile = planechaseVM.lifeCounterProfiles[i] {
                                Button(action: {
                                    cancelLastUsedSlot(slot: playerId)
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
                                    planechaseVM.lifeCounterProfiles[i].lastUsedSlot = playerId
                                    planechaseVM.saveProfiles_Info()
                                }, label: {
                                    Text(profile.name)
                                        .textButtonLabel()
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
                    Text("Cancel")
                        .textButtonLabel()
                })
            }
        }
        
        func cancelLastUsedSlot(slot: Int) {
            for i in 0..<planechaseVM.lifeCounterProfiles.count {
                if planechaseVM.lifeCounterProfiles[i].lastUsedSlot == slot {
                    planechaseVM.lifeCounterProfiles[i].lastUsedSlot = -1
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
