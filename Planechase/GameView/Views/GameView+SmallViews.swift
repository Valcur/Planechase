//
//  DiceView.swift
//  Planechase
//
//  Created by Loic D on 21/02/2023.
//

import SwiftUI

struct DiceView: View {
    @EnvironmentObject var planechaseVM: PlanechaseViewModel
    @EnvironmentObject var gameVM: GameViewModel
    @Binding var diceResult: Int
    @State private var animationAmount = 0.0
    @State var rollCost: Int = 0
    var diceResultDescription: String {
        if diceResult == -1 {
            return ""
        } else if diceResult == -2 {
            return "game_dice_pressToRoll".translate()
        } else if diceResult == 1 {
            return "game_dice_chaos".translate()
        } else if diceResult == 2 {
            return "game_dice_planechase".translate()
        } else if diceResult == 3 {
            return "game_dice_choice".translate()
        } else {
            return "game_dice_nothing".translate()
        }
    }
    
    var body: some View {
        ZStack {
            DismissCostView(rollCost: $rollCost)
                .offset(y: rollCost > 0 ? 100 : 0)
                .opacity(rollCost > 0 ? 1 : 0)
            
            Button(action: {
                rollDice()
            }, label: {
                ZStack {
                    VStack {
                        Spacer()
                        Text(diceResultDescription)
                            .foregroundColor(.white)
                            .font(.subheadline)
                            .padding(.vertical, 3)
                    }
                    
                    ZStack {
                        DiceOptions.getBackground(planechaseVM.diceOptions.diceColor)
                        
                        DiceOverlay(diceStyleId: planechaseVM.diceOptions.diceStyle, diceColorId: planechaseVM.diceOptions.diceColor)
                        
                        if diceResult == 1 {
                            Image("Chaos")
                                .resizable()
                                .renderingMode(.template)
                                .foregroundColor(DiceOptions.getForegroundColor(planechaseVM.diceOptions.diceColor))
                                .padding(10)
                        } else if diceResult == 2 {
                            Image("Planechase")
                                .resizable()
                                .renderingMode(.template)
                                .foregroundColor(DiceOptions.getForegroundColor(planechaseVM.diceOptions.diceColor))
                                .padding(5)
                        }
                        else if diceResult == 3 {
                           Image("Choice")
                               .resizable()
                               .renderingMode(.template)
                               .foregroundColor(DiceOptions.getForegroundColor(planechaseVM.diceOptions.diceColor))
                               .padding(10)
                       }
                    }.frame(width: 73, height: 73)
                    .cornerRadius(8)
                    .rotation3DEffect(.degrees(animationAmount), axis: (x: 0, y: 0, z: 1))

                    Text(rollCost > 0 ? "\(rollCost)" : "").headline().position(x: 13, y: 13)
                }.transition(.scale.combined(with: .opacity))
            })
            .disabled(gameVM.travelModeEnable)
            .frame(width: 120, height: 120)
            .background(
                VisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
                    .cornerRadius(10)
                    .shadowed()
            )
        }
    }
    
    func rollDice() {
        guard diceResult != -1 else { return }
        animationAmount = 0
        withAnimation(.spring()) {
            diceResult = -1
            self.animationAmount += 360
            rollCost += 1
        }
        
        let diceNumberOfFace = planechaseVM.diceOptions.numberOfFace

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeIn(duration: 0.1)) {
                gameVM.focusCenterToggler.toggle()
                diceResult = Int.random(in: 1...diceNumberOfFace)
                if !planechaseVM.diceOptions.useChoiceDiceFace && diceResult == 3 {
                    diceResult = diceNumberOfFace
                }
            }
        }
    }
    
    struct DismissCostView: View {
        @Binding var rollCost: Int
        var body: some View {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    rollCost = 0
                }
            }, label: {
                Text("game_dice_resetCost".translate()).textButtonLabel()
            })
        }
    }
}

struct DiceOverlay: View {
    let diceStyleId: Int
    let diceColorId: Int
    var body: some View {
        ZStack {
            if diceStyleId > 0 {
                if diceStyleId <= 4 {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(DiceOptions.getForegroundColor(diceColorId), lineWidth: 2)
                    
                    CornerImage(diceStyle: diceStyleId, diceColorId: diceColorId, alignment: .topLeading)
                    CornerImage(diceStyle: diceStyleId, diceColorId: diceColorId, alignment: .topTrailing)
                    CornerImage(diceStyle: diceStyleId, diceColorId: diceColorId, alignment: .bottomLeading)
                    CornerImage(diceStyle: diceStyleId, diceColorId: diceColorId, alignment: .bottomTrailing)
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(DiceOptions.getForegroundColor(diceColorId), lineWidth: 4)
                    
                    Image("Gear")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(DiceOptions.getForegroundColor(diceColorId))
                        .scaleEffect(1.1)
                }
            }
        }
    }
    
    struct CornerImage: View {
        let diceStyle: Int
        let diceColorId: Int
        let alignment: Alignment
        var rotation: Double {
            if alignment == .topLeading {
                return 90
            } else if alignment == .topTrailing {
                return 180
            } else if alignment == .bottomLeading {
                return 0
            } else {
                return 270
            }
        }
        var imageName: String {
            return "Corner\(diceStyle)"
        }
        
        var body: some View {
            ZStack() {
                Image(imageName)
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(DiceOptions.getForegroundColor(diceColorId))
                    .frame(width: 30, height: 30)
                    .rotationEffect(.degrees(rotation))
            }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignment).padding(4)
        }
    }
}

struct DiceView_Previews: PreviewProvider {
    static var previews: some View {
        DicePreviewBinder()
            .environmentObject(GameViewModel())
    }
    
    struct DicePreviewBinder: View {
        @State var diceResult: Int = 1
        
        var body: some View {
            DiceView(diceResult: $diceResult)
        }
    }
}

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

struct ToolView: View {
    @EnvironmentObject var gameVM: GameViewModel
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
            })
            
            VStack {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        gameVM.toggleTravelMode()
                    }
                }, label: {
                    Text(gameVM.travelModeEnable ? "game_tool_disablePlaneswalk".translate() : "game_tool_enablePlaneswalk".translate())
                        .buttonLabel()
                })
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        gameVM.togglePlanarDeckController()
                    }
                }, label: {
                    Text("game_tool_deckController".translate())
                        .buttonLabel()
                })
            }.offset(x: -60)
        }.frame(height: height).offset(y: showTools ? -height / 2 : height / 2).offset(y: -3)
    }
}

struct CurrentOtherPlanesView: View {
    @EnvironmentObject var gameVM: GameViewModel
    
    var body: some View {
        GeometryReader { geo in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(gameVM.otherCurrentPlanes, id:\.id) { card in
                        Button(action: {
                            gameVM.switchToOtherCurrentPLane(card)
                        }, label: {
                            if card.image == nil {
                                Color.black
                                    .frame(width: CardSizes.widthtForHeight(60), height: 60)
                                    .cornerRadius(CardSizes.cornerRadiusForWidth(CardSizes.widthtForHeight(60)))
                                    .onAppear {
                                        card.cardAppears()
                                    }
                            } else {
                                Image(uiImage: card.image!)
                                    .resizable()
                                    .frame(width: CardSizes.widthtForHeight(60), height: 60)
                                    .cornerRadius(CardSizes.cornerRadiusForWidth(CardSizes.widthtForHeight(60)))
                            }
                        }).shadowed(radius: 2, y: 2).padding(5)
                    }
                    
                    if gameVM.otherCurrentPlanes.count > 0 {
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                gameVM.otherCurrentPlanes = []
                            }
                        }, label: {
                            Text("discard".translate()).textButtonLabel()
                        })
                    }
                }
            }.frame(maxWidth: geo.size.width / 3).offset(x: geo.size.width / 2 + 80, y: geo.size.height / 2 - 30)
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
