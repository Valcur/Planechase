//
//  GameViewUIView.swift
//  Planechase
//
//  Created by Loic D on 02/06/2023.
//

import SwiftUI

extension GameView {
    struct RecenterView: View {
        @EnvironmentObject var gameVM: GameViewModel
        
        var body: some View {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    gameVM.focusCenterToggler.toggle()
                }
                withAnimation(.easeInOut(duration: 0.3).delay(0.3)) {
                    gameVM.cardToZoomIn = gameVM.getCenter()
                }
            }, label: {
                Image(systemName: "location.fill")
                    .imageButtonLabel()
            })
        }
    }
    
    struct LifePointsToggleView: View {
        @EnvironmentObject var gameVM: GameViewModel
        @EnvironmentObject var lifePointsViewModel: LifePointsViewModel
        
        var body: some View {
            if !gameVM.showLifePointsView {
                VStack {
                    Spacer()
                    HStack {
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                gameVM.showLifePointsView.toggle()
                            }
                        }, label: {
                            LifePointsView(isMiniView: true)
                                .environmentObject(lifePointsViewModel)
                                .ignoresSafeArea()
                                .allowsHitTesting(false)
                                .frame(width: 540, height: 300)
                                .cornerRadius(15)

                        })
                        .scaleEffect(UIDevice.isIPhone ? 0.25 : 0.38, anchor: .bottomLeading)
                        .offset(x: 1, y: 0)
                        Spacer()
                    }
                }
            }
        }
    }
    
    struct ToolView: View {
        @EnvironmentObject var gameVM: GameViewModel
        @EnvironmentObject var planechaseVM: PlanechaseViewModel
        @State var showTools = false
        private let height: CGFloat = 150
        
        var body: some View {
            VStack {
                Button(action: {
                    withAnimation(.spring()) {
                        showTools.toggle()
                    }
                }, label: {
                    Image(systemName: "hammer.fill")
                        .imageButtonLabel()
                }).opacity(planechaseVM.noHammerRow ? 0 : 1)
                
                VStack {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            gameVM.toggleTravelMode()
                        }
                    }, label: {
                        if planechaseVM.noHammerRow {
                            Image("Planechase")
                                .imageButtonLabel(customSize: 40)
                        } else {
                            Text(gameVM.travelModeEnable ? "game_tool_disablePlaneswalk".translate() : "game_tool_enablePlaneswalk".translate())
                                .buttonLabel()
                        }
                    }).offset(y: planechaseVM.noHammerRow ? 10 : 0)
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            gameVM.togglePlanarDeckController()
                        }
                    }, label: {
                        if planechaseVM.noHammerRow {
                            Image(systemName: "hammer.fill")
                                .imageButtonLabel()
                        } else {
                            Text("game_tool_deckController".translate())
                                .buttonLabel()
                        }
                    })
                }.offset(x: planechaseVM.noHammerRow ? 0 : (UIDevice.isIPhone ? -50 : -60))
            }.frame(height: height).offset(y: showTools || planechaseVM.noHammerRow ? -height / 2 : height / 2).offset(y: -3)
        }
    }
    
    struct GameInfoView: View {
        @EnvironmentObject var gameVM: GameViewModel
        
        var text: String {
            return "game_bubble_planeswalk".translate()
        }
        var showInfoView: Bool {
            return gameVM.travelModeEnable
        }
        
        var body: some View {
            Text(text).textButtonLabel(style: .secondary)
                .offset(y: showInfoView ? -100 : 0)
                .scaleEffect(1.2)
        }
    }
    
    struct ReturnToMenuView: View {
        @EnvironmentObject var planechaseVM: PlanechaseViewModel
        @State private var showingReturnAlert = false
        
        var body: some View {
            Button(action: {
                showingReturnAlert = true
            }, label: {
                Image(systemName: "xmark")
                    .imageButtonLabel()
            })
            .alert(isPresented: $showingReturnAlert) {
                Alert(
                    title: Text("game_exit_title".translate()),
                    message: Text("game_exit_content".translate()),
                    primaryButton: .destructive(Text("exit".translate())) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            planechaseVM.togglePlaying()
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }

}
