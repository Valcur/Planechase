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
        return planechaseVM.contentManagerVM.selectedCardsInCollection >= 20
    }
    var body: some View {
        ZStack {
            GradientView(gradientId: planechaseVM.gradientId)
            
            HStack {
                Spacer()
                
                ScrollView(.vertical) {
                    VStack(alignment: .leading) {
                        DiscordInvite()
                        GoingPremium()
                        Spacer()
                    }.padding(10)
                }
            }
            
            VStack {
                
                Spacer()
                
                Text("Planechase companion")
                    .title().padding(40)
                
                HStack(spacing: 50) {
                    Button(action: {
                        planechaseVM.togglePlaying()
                    }, label: {
                        Text("Play Classic")
                            .textButtonLabel()
                    }).disabled(!isAllowedToPlay)
                    
                    Button(action: {
                        planechaseVM.togglePlaying()
                    }, label: {
                        Text("Play Eternities map")
                            .textButtonLabel()
                    }).disabled(!isAllowedToPlay)
                }
                
                if !isAllowedToPlay {
                    Text("You need at least 20 cards in your deck to play")
                        .headline()
                }
                
                Spacer()
            }
        }
    }
}
