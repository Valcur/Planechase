//
//  ZoomView.swift
//  Planechase
//
//  Created by Loic D on 21/02/2023.
//

import SwiftUI

struct ZoomView: View {
    @EnvironmentObject var planechaseVM: PlanechaseViewModel
    @EnvironmentObject var gameVM: GameViewModel
    let card: Card?
    private let spacing: CGFloat = 60
    
    func cardWidth(_ screenHeight: CGFloat) -> CGFloat {
        return screenHeight - spacing
    }
    
    func cardHeight(_ screenHeight: CGFloat) -> CGFloat {
        return CardSizes.heightForWidth(screenHeight - spacing)
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                if let card = card {
                    if planechaseVM.zoomViewType == .one {
                        if UIDevice.isIPhone {
                            ZoomCardView(card: card,
                                         width: CardSizes.widthtForHeight(geo.size.height - 10))
                        } else {
                            ZoomCardView(card: card,
                                         width: cardWidth(geo.size.width * 0.9))
                        }
                    }
                    if planechaseVM.zoomViewType == .two || planechaseVM.zoomViewType == .four {
                        if UIDevice.isIPhone {
                            HStack {
                                ZoomCardView(card: card,
                                             width: geo.size.height - 10)
                                .rotationEffect(.degrees(90))
                                .offset(x: (cardWidth(geo.size.height) - cardHeight(geo.size.height)) / 2)
                                Spacer()
                                ZoomCardView(card: card,
                                             width: geo.size.height - 10)
                                .rotationEffect(.degrees(-90))
                                .offset(x: -(cardWidth(geo.size.height) - cardHeight(geo.size.height)) / 2)
                            }
                        } else {
                            HStack {
                                ZoomCardView(card: card,
                                             width: cardWidth(geo.size.height))
                                .rotationEffect(.degrees(90))
                                .offset(x: (cardWidth(geo.size.height) - cardHeight(geo.size.height)) / 2)
                                Spacer()
                                ZoomCardView(card: card,
                                             width: cardWidth(geo.size.height))
                                .rotationEffect(.degrees(-90))
                                .offset(x: -(cardWidth(geo.size.height) - cardHeight(geo.size.height)) / 2)
                            }.zIndex(2)
                        }
                    }
                    if planechaseVM.zoomViewType == .four {
                        VStack {
                            ZoomCardView(card: card,
                                         width: CardSizes.widthtForHeight(geo.size.height / 2))
                            .rotationEffect(.degrees(180))
                            .offset(y: -5)
                            Spacer()
                            ZoomCardView(card: card,
                                         width: CardSizes.widthtForHeight(geo.size.height / 2))
                            .rotationEffect(.degrees(0))
                            .offset(y: 5)
                        }.zIndex(3)
                    }
                }
            }.frame(width: geo.size.width, height: geo.size.height)
            .background(
                VisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
            ).opacity(card == nil ? 0 : 1)
            .onTapGesture {
                if !gameVM.isPlayingClassicMode {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        gameVM.cardToZoomIn = nil
                    }
                }
            }
        }.ignoresSafeArea()
    }
    
    struct ZoomCardView: View {
        @ObservedObject var card: Card
        let width: CGFloat
        var height: CGFloat {
            return CardSizes.heightForWidth(width)
        }
        
        var body: some View {
            if card.image == nil {
                Color.black
                    .frame(width: width, height: height)
                    .cornerRadius(CardSizes.cornerRadiusForWidth(width))
                    .onAppear {
                        card.cardAppears()
                    }
            } else {
                Image(uiImage: card.image!)
                    .resizable()
                    .frame(width: width, height: height)
                    .cornerRadius(CardSizes.cornerRadiusForWidth(width))
            }
        }
    }
}
