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
                    Text("game_deckController_revealTop".translate())
                        .textButtonLabel()
                })
                
                // Revealed cards
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack {
                        ForEach(gameVM.revealedCards, id: \.id) { card in
                            PlanarControllerCardView(card: card)
                        }
                    }.padding(.horizontal, 15)
                }.frame(width: geo.size.width / (UIDevice.isIPhone ? 0.8 : 1)).frame(height: CardSizes.deckController.height + 30)
                
                Button(action: {
                    gameVM.togglePlanarDeckController()
                }, label: {
                    Text(gameVM.revealedCards.count == 0 ? "exit".translate() : "game_deckController_close".translate())
                        .textButtonLabel()
                })
            }.iPhoneScaler(width: geo.size.width, height: geo.size.height).frame(width: geo.size.width, height: geo.size.height)
            .background(
                VisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark)).ignoresSafeArea()
            )
        }.opacity(gameVM.showPlanarDeckController ? 1 : 0)
    }
    
    struct PlanarControllerCardView: View {
        @EnvironmentObject var gameVM: GameViewModel
        @ObservedObject var card: Card
        
        var body: some View {
            ZStack {
                ZStack {
                    if card.image == nil {
                        Color.black
                            .opacity(0.0000001)
                            .frame(width: CardSizes.deckController.width, height: CardSizes.deckController.height)
                            .cornerRadius(CardSizes.deckController.cornerRadius)
                            .shadowed(radius: 6)
                            .padding(15)
                            .onAppear {
                                card.cardAppears()
                            }
                    } else {
                        Image(uiImage: card.image!)
                            .resizable()
                            .frame(width: CardSizes.deckController.width, height: CardSizes.deckController.height)
                            .cornerRadius(CardSizes.deckController.cornerRadius)
                            .shadowed(radius: 6)
                            .padding(15)
                    }
                }
                
                VStack {
                    HStack {
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                gameVM.putCardToBottom(card)
                            }
                        }, label: {
                            Text("game_deckController_putBottom".translate())
                                .textButtonLabel()
                        })
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                gameVM.putCardToTop(card)
                            }
                        }, label: {
                            Text("game_deckController_putTop".translate())
                                .textButtonLabel()
                        })
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                gameVM.planeswalkTo(card)
                            }
                        }, label: {
                            Text("game_deckController_planeswalk".translate())
                                .textButtonLabel()
                        })
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                gameVM.stayAndPlaneswalkTo(card)
                            }
                        }, label: {
                            Text("game_deckController_planeswalkAdd".translate())
                                .textButtonLabel()
                        })
                    }
                    Spacer()
                }
            }.padding(.horizontal, 15)
        }
    }
}
