//
//  MenuMonarchStyleChoiceView.swift
//  Planechase
//
//  Created by Loic D on 05/10/2023.
//

import SwiftUI

extension OptionsMenuView {
    struct MenuMonarchStyleChoiceView: View {
        @EnvironmentObject var planechaseVM: PlanechaseViewModel
        let styleId: Int
        var isUserAllowed: Bool {
            return planechaseVM.isPremium || styleId < 0
        }
        
        var body: some View {
            ZStack {
                Button(action: {
                    var lifeTmp = planechaseVM.lifeCounterOptions
                    lifeTmp.monarchTokenStyleId = styleId
                    planechaseVM.setLifeOptions(lifeTmp)
                }, label: {
                    MonarchTokenStyle(styleId: styleId)
                        .padding(10)
                        .overlay(RoundedRectangle(cornerRadius: 100).stroke(planechaseVM.lifeCounterOptions.monarchTokenStyleId == styleId ? .white : .clear, lineWidth: 4))
                }).disabled(!isUserAllowed).opacity(isUserAllowed ? 1 : 0.6)
                
                if !isUserAllowed {
                    Image(systemName: "crown.fill")
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .position(x: 10, y: 10)
                }
            }
        }
    }
}
