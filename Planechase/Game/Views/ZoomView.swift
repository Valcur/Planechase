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
    private let croppingGradient = Gradient(colors: [Color.black.opacity(0), Color.black.opacity(0), Color.black.opacity(0), Color.black.opacity(0.5), Color.black, Color.black, Color.black])
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                if let card = card {
                    if planechaseVM.zoomViewType == .one {
                        if UIDevice.isIPhone {
                            ZoomCardView(card: card,
                                         width: CardSizes.widthtForHeight(geo.size.height/* - 10*/))
                            .shadowed()
                        } else {
                            ZoomCardView(card: card,
                                         width: cardWidth(geo.size.width * 0.9))
                            .shadowed()
                        }
                    }
                    if planechaseVM.zoomViewType == .two || planechaseVM.zoomViewType == .four {
                        if UIDevice.isIPhone {
                            HStack {
                                ZoomCardView(card: card,
                                             width: geo.size.height - 10)
                                .rotationEffect(.degrees(90))
                                .offset(x: (cardWidth(geo.size.height) - cardHeight(geo.size.height)) / 2)
                                .shadowed()
                                Spacer()
                                ZoomCardView(card: card,
                                             width: geo.size.height - 10)
                                .rotationEffect(.degrees(-90))
                                .offset(x: -(cardWidth(geo.size.height) - cardHeight(geo.size.height)) / 2)
                                .shadowed()
                            }
                        } else {
                            HStack {
                                ZoomCardView(card: card,
                                             width: cardWidth(geo.size.height))
                                .rotationEffect(.degrees(90))
                                .offset(x: (cardWidth(geo.size.height) - cardHeight(geo.size.height)) / 2)
                                .shadowed()
                                Spacer()
                                ZoomCardView(card: card,
                                             width: cardWidth(geo.size.height))
                                .rotationEffect(.degrees(-90))
                                .offset(x: -(cardWidth(geo.size.height) - cardHeight(geo.size.height)) / 2)
                                .shadowed()
                            }.zIndex(2)
                        }
                    }
                    if planechaseVM.zoomViewType == .four {
                        VStack {
                            ZoomCardView(card: card,
                                         width: CardSizes.widthtForHeight(geo.size.height / 2))
                            .rotationEffect(.degrees(180))
                            .offset(y: -5)
                            .shadowed()
                            Spacer()
                            ZoomCardView(card: card,
                                         width: CardSizes.widthtForHeight(geo.size.height / 2))
                            .rotationEffect(.degrees(0))
                            .offset(y: 5)
                            .shadowed()
                        }.zIndex(3)
                    }
                    if planechaseVM.zoomViewType == .two_cropped {
                        ZStack {
                            VStack {
                                Spacer()
                                ZoomCardView(card: card,
                                             width: min(CardSizes.widthtForHeight(geo.size.height), geo.size.width * 0.80))
                                .offset(y: 5)
                            }
                            .mask(
                                LinearGradient(gradient: croppingGradient, startPoint: .top, endPoint: .bottom)
                            )
                            .rotationEffect(.degrees(180))
                            
                            VStack {
                                Spacer()
                                ZoomCardView(card: card,
                                             width: min(CardSizes.widthtForHeight(geo.size.height), geo.size.width * 0.80))
                                .offset(y: 5)
                            }
                            .mask(
                                LinearGradient(gradient: croppingGradient, startPoint: .top, endPoint: .bottom)
                            )
                        }.shadowed()
                    }
                }
            }.frame(width: geo.size.width, height: geo.size.height)
            .background(
                ZStack {
                    if planechaseVM.useBlurredBackground, let card = card {
                        CardImageBackground(card: card, blurRadius: 8)
                    } else {
                        VisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
                    }
                }.ignoresSafeArea()
            ).opacity(card == nil ? 0 : 1)
            .onTapGesture {
                if !gameVM.isPlayingClassicMode {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        gameVM.cardToZoomIn = nil
                    }
                }
            }
        }
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

struct CardImageBackground: View {
    @ObservedObject var card: Card
    let blurRadius: CGFloat

    var body: some View {
        GeometryReader { geo in
            if let image = card.image {
                Image(uiImage: image)
                    .resizable()
                    .blur(radius: blurRadius)
                    .contrast(0.85)
                    .scaleEffect(2.5)
                    .scaledToFill()
                    .offset(y: geo.size.height * 0.25)
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
            }
        }
    }
}
