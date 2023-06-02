//
//  MenuCustomBackgroundColorChoiceView.swift
//  Planechase
//
//  Created by Loic D on 02/06/2023.
//

import SwiftUI

extension OptionsMenuView {
    struct MenuCustomBackgroundColorChoiceView: View {
        @EnvironmentObject var planechaseVM: PlanechaseViewModel
        let gradientId: Int
        
        var body: some View {
            Button(action: {
                print("Changing background color to \(gradientId)")
                planechaseVM.setGradientId(gradientId)
            }, label: {
                GradientView(gradientId: gradientId).cornerRadius(15).frame(width: 120, height: 120).overlay(
                    RoundedRectangle(cornerRadius: 19).stroke(planechaseVM.gradientId == gradientId ? .white : .clear, lineWidth: 4)).padding(10)
            })
        }
    }
}
