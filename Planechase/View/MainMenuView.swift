//
//  MainMenuView.swift
//  Planechase
//
//  Created by Loic D on 20/02/2023.
//

import SwiftUI

struct MainMenuView: View {
    @EnvironmentObject var planechaseVM: PlanechaseViewModel
    var isAllowedToPlayClassic: Bool {
        return planechaseVM.contentManagerVM.selectedCardsInCollection >= 10
    }
    var isAllowedToPlayEternities: Bool {
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
                
                Text("play_app_title".translate())
                    .title().padding(40)
                
                HStack(spacing: 50) {
                    Button(action: {
                        planechaseVM.togglePlaying(classicGameMode: true)
                    }, label: {
                        Text("play_playClassic".translate())
                            .textButtonLabel()
                    }).disabled(!isAllowedToPlayClassic)
                    
                    Button(action: {
                        planechaseVM.togglePlaying(classicGameMode: false)
                    }, label: {
                        Text("play_playEternities".translate())
                            .textButtonLabel()
                    }).disabled(!isAllowedToPlayEternities)
                }
                
                if !isAllowedToPlayClassic {
                    Text("play_playClassic_needMoreCards".translate())
                        .headline()
                }
                
                if !isAllowedToPlayEternities {
                    Text("play_playEternities_needMoreCards".translate())
                        .headline()
                }
                
                Spacer()
            }.scaleEffect(UIDevice.isIPad ? 1 : 0.9)
        }.ignoresSafeArea()
    }
}
