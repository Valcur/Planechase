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
        private let height: CGFloat = 200
        @State var size: CGSize = .zero
        
        var body: some View {
            ChildSizeReader(size: $size) {
                VStack(alignment: .trailing, spacing: 0) {
                    if !planechaseVM.noHammerRow {
                        Button(action: {
                            withAnimation(.spring()) {
                                showTools.toggle()
                            }
                        }, label: {
                            Image(systemName: "hammer.fill")
                                .imageButtonLabel()
                        })
                    }
                    
                    if gameVM.isPlayingClassicMode {
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                gameVM.cancelPlaneswalk()
                            }
                        }, label: {
                            if planechaseVM.noHammerRow {
                                Image(systemName: "arrow.uturn.backward")
                                    .imageButtonLabel()
                            } else {
                                Text("game_tool_previousPlane".translate())
                                    .textButtonLabel()
                            }
                        }).disabled(gameVM.previousPlane == nil)
                        .opacity(gameVM.previousPlane == nil ? 0.6 : 1)
                    }
                    
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
                                .textButtonLabel()
                        }
                    })
                    
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
                                .textButtonLabel()
                        }
                    })
                }.frame(width: 300, alignment: .trailing).offset(y: showTools || planechaseVM.noHammerRow ? -size.height / 2 + 35 : size.height / 2 - 35)
                    .offset(x: -115)
            }
        }
        
        struct ChildSizeReader<Content: View>: View {
            @Binding var size: CGSize
            let content: () -> Content
            var body: some View {
                ZStack {
                    content()
                        .background(
                            GeometryReader { proxy in
                                Color.clear
                                    .preference(key: SizePreferenceKey.self, value: proxy.size)
                            }
                        )
                }
                .onPreferenceChange(SizePreferenceKey.self) { preferences in
                    self.size = preferences
                }
            }
        }

        struct SizePreferenceKey: PreferenceKey {
            typealias Value = CGSize
            static var defaultValue: Value = .zero

            static func reduce(value _: inout Value, nextValue: () -> Value) {
                _ = nextValue()
            }
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
