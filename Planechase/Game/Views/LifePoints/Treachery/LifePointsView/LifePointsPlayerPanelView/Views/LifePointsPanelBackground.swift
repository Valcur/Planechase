//
//  LifePointsPanelBackground.swift
//  LifeCounter
//
//  Created by Loic D on 30/10/2023.
//

import SwiftUI

extension LifePointsPlayerPanelView {
    struct LifePointsPanelBackground: View {
        @EnvironmentObject var planechaseVM: PlanechaseViewModel
        @Binding var player: PlayerProfile
        let isMiniView: Bool
        let isPlayerOnOppositeSide: Bool
        let gradientOverlay = Gradient(colors: [.black.opacity(0.2), .black.opacity(0.1), .black.opacity(0.1), .black.opacity(0.1), .black.opacity(0.2)])
        let blurEffect: UIBlurEffect.Style = .systemChromeMaterialDark
        
        var body: some View {
            Group {
                if let image = player.backgroundImage {
                    ZStack {
                        GeometryReader { geo in
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .clipped()
                        }
                        if !isMiniView {
                            LinearGradient(gradient: gradientOverlay, startPoint: .leading, endPoint: .trailing)
                        }
                    }
                } else {
                    if planechaseVM.lifeCounterOptions.colorPaletteId == -1 {
                        ZStack {
                            if !isMiniView {
                                Color.gray.opacity(0.4)
                                GeometryReader { geo in
                                    Image("VignetteOverlay")
                                        .resizable()
                                        .clipped()
                                }
                            }
                            VisualEffectView(effect: UIBlurEffect(style: blurEffect))
                        }
                    } else {
                        if let backgroundStyle = planechaseVM.lifeCounterOptions.backgroundStyleId, backgroundStyle >= 0 {
                            ZStack {
                                GeometryReader { geo in
                                    CustomBackgroundStyle.getSelectedBackgroundImage(backgroundStyle)
                                        .scaledToFill()
                                        .colorMultiply(player.backgroundColor)
                                        .clipped()
                                }
                                if backgroundStyle == 0 || backgroundStyle == 1 {
                                    GeometryReader { geo in
                                        Image("VignetteOverlay")
                                            .resizable()
                                            .clipped()
                                            .opacity(isMiniView ? 0.2 : 0.4)
                                    }
                                }
                            }
                        } else {
                            player.backgroundColor
                        }
                    }
                }
                
                if planechaseVM.treacheryOptions.isTreacheryEnabled && !isMiniView {
                    TreacheryCardView(player: $player, putCardOnTheRight: isPlayerOnOppositeSide)
                }
                
                Color.black.opacity(0.1)
            }.allowsHitTesting(false)
        }
        
        func getGradient(_ color: Color) -> Gradient {
            return Gradient(colors: [color.opacity(0.8), color.opacity(0.3), color.opacity(0.3), color.opacity(0.3), color.opacity(0.8)])
        }
    }
}
