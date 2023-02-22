//
//  MainMenuView.swift
//  Planechase
//
//  Created by Loic D on 20/02/2023.
//

import SwiftUI

struct MainMenuView: View {
    @EnvironmentObject var planechaseVM: PlanechaseViewModel
    
    var body: some View {
        ZStack {
            GradientView(gradientId: 1)
            
            VStack {
                Text("Eternities map")
                    .title()
                Text("You need at least 40 cards selected")
                    .headline()
                
                Button(action: {
                    planechaseVM.togglePlaying()
                }, label: {
                    Text("Play")
                        .buttonLabel()
                })
            }
        }
    }
}
