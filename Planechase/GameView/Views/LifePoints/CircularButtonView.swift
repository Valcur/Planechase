//
//  CircularButtonView.swift
//  Planechase
//
//  Created by Loic D on 25/10/2023.
//

import SwiftUI

struct CircularButtonView: View {
    @EnvironmentObject var planechaseVM: PlanechaseViewModel
    @EnvironmentObject var lifePointsViewModel: LifePointsViewModel
    @State var showMenu: Bool = true
    let buttons: [AnyView]
    @Binding var lifepointHasBeenUsedToggler: Bool
    @State private var showingRestartAlert = false
    
    var body: some View {
        ZStack {
            if UIDevice.isIPhone {
                HStack(alignment: .top) {
                    Button(action: {
                        withAnimation(.spring()) {
                            showMenu.toggle()
                        }
                        lifepointHasBeenUsedToggler.toggle()
                    }, label: {
                        Image(systemName: "chevron.right")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 40, height: 40)
                            .rotationEffect(.degrees(showMenu ? 180 : 0))
                            .offset(x: UIDevice.isIPhone ? 15 : 0)
                    })
                    
                    if showMenu {
                        VStack {
                            Spacer()
                            
                            Button(action: {
                                showingRestartAlert = true
                            }, label: {
                                Image(systemName: "arrow.counterclockwise")
                                    .font(.title)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(width: 40, height: 40)
                            })
                            
                            buttons[0]
                            buttons[1]
                            buttons[2]
                            
                            Spacer()
                        }.padding(.top, 50)
                    }
                }
            } else {
                VStack {
                    Spacer()
                    
                    Button(action: {
                        showingRestartAlert = true
                    }, label: {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 40, height: 40)
                    })
                    
                    buttons[0]
                    buttons[1]
                    buttons[2]
                    
                    Spacer()
                }.padding(.top, 50)
            }
        }
        .alert(isPresented: $showingRestartAlert) {
            Alert(
                title: Text("game_exit_title".translate()),
                message: Text("game_exit_content".translate()),
                primaryButton: .destructive(Text("confirm".translate())) {
                    lifePointsViewModel.newGame(numberOfPlayer: planechaseVM.lifeCounterOptions.nbrOfPlayers,
                                                startingLife: planechaseVM.lifeCounterOptions.startingLife, colorPalette: planechaseVM.lifeCounterOptions.colorPaletteId, playWithTreachery: planechaseVM.treacheryOptions.isTreacheryEnabled,
                                                treacheryData: planechaseVM.treacheryData,
                                                customProfiles: planechaseVM.lifeCounterProfiles)
                },
                secondaryButton: .cancel()
            )
        }
    }
}
