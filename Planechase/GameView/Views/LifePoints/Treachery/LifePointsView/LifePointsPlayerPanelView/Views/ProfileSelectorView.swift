//
//  ProfileSelectorView.swift
//  LifeCounter
//
//  Created by Loic D on 05/11/2023.
//

import SwiftUI

extension LifePointsPlayerPanelView {
    struct ProfileSelector: View {
        @EnvironmentObject var lifePointsViewModel: LifePointsViewModel
        @EnvironmentObject var planechaseVM: PlanechaseViewModel
        let playerId: Int
        @Binding var player: PlayerProfile
        @Binding var lifepointHasBeenUsedToggler: Bool
        let columns = [
                GridItem(.flexible()),
                GridItem(.flexible())
            ]
        
        var body: some View {
            ZStack {
                if planechaseVM.lifeCounterProfiles.count == 0 {
                    Text("options_noProfilesYet").headline()
                        .padding(.horizontal, 30)
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack {
                            Button(action: {
                                applyProfile(profile: nil, slot: playerId)
                            }, label: {
                                Text("lifepoints_noProfile".translate())
                                    .textButtonLabel()
                            }).padding(.top, 5)
                            LazyVGrid(columns: columns, spacing: 5) {
                                ForEach(0..<planechaseVM.lifeCounterProfiles.count, id: \.self) { i in
                                    if let profile = planechaseVM.lifeCounterProfiles[i] {
                                        Button(action: {
                                            applyProfile(profile: profile, slot: playerId)
                                        }, label: {
                                            ProfileSelectorView(profile: profile, isSelected: player.id == profile.id)
                                        }).padding(0)
                                    }
                                }
                            }.frame(maxWidth: .infinity).padding(5)
                        }
                    }
                }
            }.frame(maxWidth: .infinity, maxHeight: .infinity).background(VisualEffectView(effect: UIBlurEffect(style: UIBlurEffect.Style.systemMaterialDark))).border(Color.black, width: 2)
        }
        
        struct ProfileSelectorView: View {
            let profile: PlayerCustomProfileInfo
            let isSelected: Bool
            var body: some View {
                GeometryReader { geo in
                    ZStack {
                        if let image = profile.customImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: geo.size.width, height: 150).clipped()
                        }
                        Color.black.opacity(0.2)
                        Text(profile.name)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }.border(Color.white, width: isSelected ? 2 : 0).frame(height: 150)
            }
        }
        
        func applyProfile(profile: PlayerCustomProfileInfo?, slot: Int) {
            if let profile = profile {
                withAnimation(.easeInOut(duration: 0.3)) {
                    var backgroundImage: UIImage? = nil
                    if let image = profile.customImage {
                        backgroundImage = image
                    }
                    
                    player.backgroundImage = backgroundImage
                    player.id = profile.id
                    player.name = profile.name
                }
            } else {
                withAnimation(.easeInOut(duration: 0.3)) {
                    player.backgroundImage = nil
                    player.id = UUID()
                    player.name = "\("lifepoints_player".translate()) \(playerId + 1)"
                }
            }
            lifepointHasBeenUsedToggler.toggle()
            lifePointsViewModel.lastUsedSetup.playersProfilesIds[playerId] = profile == nil ? nil : profile!.id
            cancelLastUsedSlot(slot: playerId)
        }
        
        func cancelLastUsedSlot(slot: Int) {
            for i in 0..<lifePointsViewModel.players.count {
                if lifePointsViewModel.players[i].id == player.id && i != slot {
                    print("Found at \(i) for \(slot)")
                    withAnimation(.easeInOut(duration: 0.3)) {
                        lifePointsViewModel.lastUsedSetup.playersProfilesIds[i] = nil
                        lifePointsViewModel.players[i].backgroundImage = nil
                        lifePointsViewModel.players[i].id = UUID()
                        lifePointsViewModel.players[i].name = "\("lifepoints_player".translate()) \(i + 1)"
                    }
                }
            }
        }
    }
}
