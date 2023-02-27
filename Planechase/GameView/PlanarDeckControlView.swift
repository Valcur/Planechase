//
//  PlanarDeckControlView.swift
//  Planechase
//
//  Created by Loic D on 26/02/2023.
//

import SwiftUI

struct PlanarDeckControlView: View {
    @EnvironmentObject var gameVM: GameViewModel
    
    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 20) {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        gameVM.revealTopPlanarDeckCard()
                    }
                }, label: {
                    Text("Reveal top card")
                        .textButtonLabel()
                })
                
                // Revealed cards
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack {
                        ForEach(gameVM.revealedCards, id: \.id) { card in
                            PlanarControllerCardView(card: card)
                        }
                    }.padding(.horizontal, 15)
                }.frame(width: geo.size.width).frame(height: CardSizes.deckController.height + 100)
                
                Button(action: {
                    gameVM.togglePlanarDeckController()
                }, label: {
                    Text("Put all revealed card at the bottom in a random order and leave")
                        .textButtonLabel()
                })
            }.iPhoneScaler(width: geo.size.width, height: geo.size.height).frame(width: geo.size.width, height: geo.size.height)
            .background(
                VisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
            )
        }.opacity(gameVM.showPlanarDeckController ? 1 : 0)
    }
    
    struct PlanarControllerCardView: View {
        @EnvironmentObject var gameVM: GameViewModel
        @ObservedObject var card: Card
        
        var body: some View {
            VStack {
                ZStack {
                    if card.image == nil {
                        Color.black
                            .opacity(0.0000001)
                            .frame(width: CardSizes.deckController.width, height: CardSizes.deckController.height)
                            .cornerRadius(CardSizes.deckController.cornerRadius)
                            .shadowed(radius: 8)
                            .onAppear {
                                card.cardAppears()
                            }
                    } else {
                        Image(uiImage: card.image!)
                            .resizable()
                            .frame(width: CardSizes.deckController.width, height: CardSizes.deckController.height)
                            .cornerRadius(CardSizes.deckController.cornerRadius)
                            .shadowed(radius: 8)
                    }
                }
                .padding(5)
                
                HStack {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            gameVM.putCardToBottom(card)
                        }
                    }, label: {
                        Text("Put bottom")
                            .textButtonLabel()
                    })
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            gameVM.putCardToTop(card)
                        }
                    }, label: {
                        Text("Put top")
                            .textButtonLabel()
                    })
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            gameVM.planeswalkTo(card)
                        }
                    }, label: {
                        Text("Planeswalk")
                            .textButtonLabel()
                    })
                }
            }
        }
    }
}
