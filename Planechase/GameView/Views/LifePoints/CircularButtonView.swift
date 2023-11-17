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
    
    var body: some View {
        ZStack {
            if UIDevice.isIPhone {
                HStack(alignment: .top) {
                    VStack {
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
                                .offset(x: 14, y: 10)
                        })
                        Spacer()
                    }
                    
                    if showMenu {
                        VStack {
                            Spacer()
                            
                            buttons[0]
                            buttons[1]
                            buttons[2]
                            buttons[3]
                            
                            Spacer()
                        }
                    }
                }
            } else {
                VStack {
                    Spacer()
                    
                    buttons[0]
                    buttons[1]
                    buttons[2]
                    buttons[3]
                    
                    Spacer()
                }
            }
        }
    }
}
