//
//  MainMenuView.swift
//  Planechase
//
//  Created by Loic D on 20/02/2023.
//

import SwiftUI

struct MainMenuView: View {
    @EnvironmentObject var planechaseVM: PlanechaseViewModel
    var isAllowedToPlay: Bool {
        return planechaseVM.contentManagerVM.selectedCardsInCollection >= 30
    }
    var body: some View {
        ZStack {
            GradientView(gradientId: planechaseVM.gradientId)
            
            HStack {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading) {
                        DiscordInvite()
                        GoingPremium()
                        Spacer()
                    }.padding(10).scaleEffect(UIDevice.isIPhone ? 0.8 : 1, anchor: .topLeading)
                }
                
                Spacer()
            }
            
            VStack {
                
                Spacer()
                
                Text("Planechase companion")
                    .title().padding(40)
                
                HStack(spacing: 50) {
                    Button(action: {
                        planechaseVM.togglePlaying(classicGameMode: true)
                    }, label: {
                        Text("Play Classic")
                            .textButtonLabel()
                    }).disabled(!isAllowedToPlay)
                    
                    Button(action: {
                        planechaseVM.togglePlaying(classicGameMode: false)
                    }, label: {
                        Text("Play Eternities map")
                            .textButtonLabel()
                    }).disabled(!isAllowedToPlay)
                }
                
                if !isAllowedToPlay {
                    Text("You need at least 30 cards in your deck to play")
                        .headline()
                }
                
                Spacer()
            }.scaleEffect(UIDevice.isIPad ? 1 : 0.9)
        }.ignoresSafeArea()
    }
}
