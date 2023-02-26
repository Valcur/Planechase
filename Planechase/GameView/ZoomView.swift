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
        return Card.heightForWidth(screenHeight - spacing)
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                if let card = card {
                    if planechaseVM.zoomViewType == .one {
                        ZoomCardView(card: card,
                                     width: cardWidth(geo.size.width * 0.9))
                    }
                    if planechaseVM.zoomViewType == .two || planechaseVM.zoomViewType == .four {
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
                        }
                    }
                    if planechaseVM.zoomViewType == .four {
                        VStack {
                            ZoomCardView(card: card,
                                         width: cardWidth(geo.size.width / 1.7))
                            .rotationEffect(.degrees(180))
                            .offset(y: 0)
                            Spacer()
                            ZoomCardView(card: card,
                                         width: cardWidth(geo.size.width / 1.7))
                            .rotationEffect(.degrees(0))
                            .offset(y: 0)
                        }
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
            return Card.heightForWidth(width)
        }
        
        var body: some View {
            if card.image == nil {
                Color.black
                    .frame(width: width, height: height)
                    .cornerRadius(width / 28)
                    .onAppear {
                        card.cardAppears()
                    }
            } else {
                Image(uiImage: card.image!)
                    .resizable()
                    .frame(width: width, height: height)
                    .cornerRadius(width / 25)
            }
        }
    }
}
