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
    var showLeftSection: Bool {
        return whatsNew.showWhatsNew || !planechaseVM.isPremium || planechaseVM.showDiscordInvite
    }
    var body: some View {
        HStack(spacing: 0) {
            if showLeftSection {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading) {
                        WhatsNew(whatsNew: whatsNew)
                        DiscordInvite()
                        GoingPremium()
                        Spacer()
                    }.scaleEffect(UIDevice.isIPhone ? 0.7 : 1, anchor: .top).frame(maxWidth: UIDevice.isIPhone ? BubbleSizes.width * 0.6 : BubbleSizes.width * BubbleSizes.scale).padding(.vertical, UIDevice.isIPhone ? 6 : 10).padding(.horizontal, UIDevice.isIPhone ? 3 : 10)
                }.frame(maxHeight: .infinity)
            }
            
            ZStack(alignment: .bottom) {
                VStack(alignment: .leading) {
                    Text("play_app_title".translate())
                        .largeTitle().padding(UIDevice.isIPhone ? 10 : 40)
                    HStack(spacing: 10) {
                        Button(action: {
                            planechaseVM.togglePlaying(classicGameMode: true)
                        }, label: {
                            ZStack {
                                LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.6), Color.black.opacity(0)]), startPoint: .bottom, endPoint: .top)
                                VStack(spacing: 15) {
                                    Text("play_mode".translate())
                                        .headline()
                                    Text("play_playClassic".translate())
                                        .title()
                                    
                                    if !isAllowedToPlayClassic {
                                        Rectangle().opacity(0.00001).frame(height: 45)
                                    }
                                    
                                    if !isAllowedToPlayEternities {
                                        Rectangle().opacity(0.00001).frame(height: 45)
                                    }
                                }
                            }
                        }).disabled(!isAllowedToPlayClassic).opacity(isAllowedToPlayClassic ? 1 : 0.7)
                        
                        Button(action: {
                            planechaseVM.togglePlaying(classicGameMode: false)
                        }, label: {
                            ZStack {
                                LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.6), Color.black.opacity(0)]), startPoint: .bottom, endPoint: .top)
                                VStack(spacing: 15) {
                                    Text("play_mode".translate())
                                        .headline()
                                    Text("play_playEternities".translate())
                                        .title()
                                    
                                    if !isAllowedToPlayClassic {
                                        Rectangle().opacity(0.00001).frame(height: 45)
                                    }
                                    
                                    if !isAllowedToPlayEternities {
                                        Rectangle().opacity(0.00001).frame(height: 45)
                                    }
                                }
                            }
                        }).disabled(!isAllowedToPlayEternities).opacity(isAllowedToPlayEternities ? 1 : 0.7)
                    }
                }
                
                VStack(spacing: UIDevice.isIPhone ? 3 : 10) {
                    if !isAllowedToPlayClassic {
                        Text("play_playClassic_needMoreCards".translate())
                            .textButtonLabel(style: .secondary)
                    }
                    
                    if !isAllowedToPlayEternities {
                        Text("play_playEternities_needMoreCards".translate())
                            .textButtonLabel(style: .secondary)
                    }
                }.padding(.bottom, UIDevice.isIPhone ? 10 : 20)
            }
        }.background(GradientView(gradientId: planechaseVM.gradientId).ignoresSafeArea())
    }
}
