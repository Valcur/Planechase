//
//  ZoomView.swift
//  Planechase
//
//  Created by Loic D on 21/02/2023.
//

import SwiftUI

struct ZoomView: View {
    @EnvironmentObject var gameVM: GameViewModel
    @State var card: Card
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
                HStack {
                    ZoomCardView(card: card,
                                 width: cardWidth(geo.size.height),
                                 height: cardHeight(geo.size.height))
                        .rotationEffect(.degrees(90))
                        .offset(x: (cardWidth(geo.size.height) - cardHeight(geo.size.height)) / 2)
                    Spacer()
                    ZoomCardView(card: card,
                                 width: cardWidth(geo.size.height),
                                 height: cardHeight(geo.size.height))
                        .rotationEffect(.degrees(-90))
                        .offset(x: -(cardWidth(geo.size.height) - cardHeight(geo.size.height)) / 2)
                }
                Button(action: {
                    gameVM.cardToZoomIn = nil
                }, label: {
                    Text("Hide")
                        .buttonLabel()
                })
            }.frame(width: geo.size.width, height: geo.size.height)
            .background(
                VisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
                    .cornerRadius(10)
                    .shadow(color: Color.black, radius: 4, x: 0, y: 4)
            )
        }.ignoresSafeArea()
    }
    
    struct ZoomCardView: View {
        var card: Card
        let width: CGFloat
        let height: CGFloat
        
        var body: some View {
            if card.image == nil {
                Color.black
                    .frame(width: width, height: height)
                    .cornerRadius(width / 28)
                    .onAppear {
                        card.cardAppears()
                    }
            } else {
                card.image!
                    .resizable()
                    .frame(width: width, height: height)
                    .cornerRadius(width / 25)
            }
        }
    }
}
