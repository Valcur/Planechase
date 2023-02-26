//
//  DiceView.swift
//  Planechase
//
//  Created by Loic D on 21/02/2023.
//

import SwiftUI

struct DiceView: View {
    @EnvironmentObject var gameVM: GameViewModel
    @Binding var diceResult: Int
    @State private var animationAmount = 0.0
    @State var rollCost: Int = 0
    var diceResultDescription: String {
        if diceResult == -1 {
            return ""
        } else if diceResult == -2 {
            return "Press to roll"
        } else if diceResult == 1 {
            return "Chaos"
        } else if diceResult == 6 {
            return "Planechase"
        } else {
            return "Nothing"
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
                            .padding(.vertical, 5)
                    }
                    
                    ZStack {
                        Color.black
                            .opacity(0.3)
                        
                        if diceResult == 1 {
                            Image("Chaos")
                                .resizable()
                                .foregroundColor(.white)
                                .padding(10)
                        } else if diceResult == 6 {
                            Image("Planechase")
                                .resizable()
                                .foregroundColor(.white)
                                .padding(10)
                        }
                    }.frame(width: 75, height: 75)
                    .cornerRadius(8)
                    .rotation3DEffect(.degrees(animationAmount), axis: (x: 0, y: 0, z: 1))

                    Text(rollCost > 0 ? "\(rollCost)" : "").headline().position(x: 15, y: 15)
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

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.spring()) {
                gameVM.focusCenterToggler.toggle()
                diceResult = Int.random(in: 1...6)
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
                Text("Reset cost").textButtonLabel()
            })
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
                    Text(gameVM.travelModeEnable ? "Disable Planeswalk" : "Enable Planeswalk")
                        .buttonLabel()
                })
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        gameVM.togglePlanarDeckController()
                    }
                }, label: {
                    Text("Deck Controller")
                        .buttonLabel()
                })
            }.offset(x: -60)
        }.frame(height: height).offset(y: showTools ? -height / 2 : height / 2).offset(y: -3)
    }
}

struct GameInfoView: View {
    @EnvironmentObject var gameVM: GameViewModel
    
    var text: String {
        return "Hold on a plane to travel"
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
                title: Text("Are you sure you want to return to main menu ?"),
                message: Text("Game will be lost"),
                primaryButton: .destructive(Text("Exit")) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        planechaseVM.togglePlaying()
                    }
                },
                secondaryButton: .cancel()
            )
        }
    }
}
