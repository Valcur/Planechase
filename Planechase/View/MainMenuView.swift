//
//  MainMenuView.swift
//  Planechase
//
//  Created by Loic D on 20/02/2023.
//

import SwiftUI

struct MainMenuView: View {
    @EnvironmentObject var planechaseVM: PlanechaseViewModel
    @ObservedObject var whatsNew = WhatsNewController()
    var isAllowedToPlayClassic: Bool {
        return planechaseVM.contentManagerVM.selectedCardsInCollection >= 10
    }
    var isAllowedToPlayEternities: Bool {
        return planechaseVM.contentManagerVM.selectedCardsInCollection >= 30
    }
    var body: some View {
        ZStack {
            HStack {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading) {
                        WhatsNew(whatsNew: whatsNew)
                        DiscordInvite()
                        GoingPremium()
                        Spacer()
                    }.padding(10).scaleEffect(UIDevice.isIPhone ? 0.75 : 1, anchor: .topLeading)
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
                    }).disabled(!isAllowedToPlayClassic).opacity(isAllowedToPlayClassic ? 1 : 0.7)
                    
                    Button(action: {
                        planechaseVM.togglePlaying(classicGameMode: false)
                    }, label: {
                        Text("play_playEternities".translate())
                            .textButtonLabel()
                    }).disabled(!isAllowedToPlayEternities).opacity(isAllowedToPlayEternities ? 1 : 0.7)
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
            }.scaleEffect(UIDevice.isIPad ? 1 : 0.9).padding(.leading, UIDevice.isIPhone && (planechaseVM.showDiscordInvite || !planechaseVM.isPremium || whatsNew.showWhatsNew) ? 200 : 0)
        }.background(GradientView(gradientId: planechaseVM.gradientId).ignoresSafeArea())
    }
}
