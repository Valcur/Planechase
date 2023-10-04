//
//  MenuLifeCounterBackgroundStyleChoiceView.swift
//  Planechase
//
//  Created by Loic D on 03/10/2023.
//

import SwiftUI

extension OptionsMenuView {
    struct MenuLifeCounterBackgroundStyleChoiceView: View {
        @EnvironmentObject var planechaseVM: PlanechaseViewModel
        let backgroundStyleId: Int
        var isUserAllowed: Bool {
            return planechaseVM.isPremium || backgroundStyleId < 0
        }
        @State var colorId = 1
        
        var body: some View {
            ZStack {
                Button(action: {
                    var lifeTmp = planechaseVM.lifeCounterOptions
                    lifeTmp.backgroundStyleId = backgroundStyleId
                    planechaseVM.setLifeOptions(lifeTmp)
                }, label: {
                    VStack {
                        if backgroundStyleId == -1 {
                            Color("\(planechaseVM.lifeCounterOptions.colorPaletteId) Player \(colorId)")
                        } else {
                            if backgroundStyleId >= 0 {
                                CustomBackgroundStyle.getSelectedBackgroundImage(backgroundStyleId)
                                    .scaledToFill()
                                    .colorMultiply(Color("\(planechaseVM.lifeCounterOptions.colorPaletteId) Player \(colorId)"))
                            }
                        }
                    }.frame(width: 120, height: 120).clipped().cornerRadius(15).overlay(
                        RoundedRectangle(cornerRadius: 19)
                            .stroke(planechaseVM.lifeCounterOptions.backgroundStyleId == backgroundStyleId ? .white : .clear, lineWidth: 4))
                    .padding(10)
                }).disabled(!isUserAllowed).opacity(isUserAllowed ? 1 : 0.6)
                    .onAppear() {
                        colorId = 1
                        changeColorMultiplier()
                    }
                    .onDisappear() {
                        colorId = 0
                    }
                
                if !isUserAllowed {
                    Image(systemName: "crown.fill")
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .position(x: 10, y: 10)
                }
            }
        }
        
        func changeColorMultiplier() {
            if colorId == 0 { return }
            print("Change color")
            let duration: CGFloat = 2
            withAnimation(.easeInOut(duration: 0.3)) {
                colorId += 1
                if colorId > 8 {
                    colorId = 1
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                changeColorMultiplier()
            }
        }
    }
}

struct CustomBackgroundStyle {
    static let paper: Image = Image("PaperTexture").resizable()
    static let concrete1: Image = Image("Concrete1").resizable()
    static let concrete2: Image = Image("Concrete2").resizable()
    
    static func getSelectedBackgroundImage(_ styleId: Int) -> Image {
        if styleId == 1 {
            return CustomBackgroundStyle.concrete1
        } else if styleId == 2 {
            return CustomBackgroundStyle.concrete2
        }
        return CustomBackgroundStyle.paper
    }
}
