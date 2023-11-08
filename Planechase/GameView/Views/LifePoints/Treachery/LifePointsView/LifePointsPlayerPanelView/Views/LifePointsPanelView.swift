//
//  LifePointsPanelView.swift
//  Planechase
//
//  Created by Loic D on 29/10/2023.
//

import SwiftUI

struct LifePointsPanelView: View {
    @EnvironmentObject var lifePointsViewModel: LifePointsViewModel
    
    let playerName: String
    @Binding var lifepoints: Int
    @Binding var totalChange: Int
    let isMiniView: Bool
    let inverseChangeSide: Bool
    let isPlayerOnSide: Bool
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Spacer()
                if !isMiniView {
                    Text(playerName)
                        .font(.system(size: (UIDevice.isIPhone ? 15 : 20)))
                        .foregroundColor(.white)
                        .shadow(color: isMiniView ? .clear : Color("ShadowColorDarker"), radius: 3, x: 0, y: 0)
                        .frame(height: 20)
                        .offset(y: 10)
                }
                
                Text("\(lifepoints)")
                    .font(.system(size: isMiniView ? 80 : (UIDevice.isIPhone ? 60 : 110)))
                    //.fontWeight(.bold)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .shadow(color: isMiniView ? .clear : Color("ShadowColorDarker"), radius: 3, x: 0, y: 0)
                
                if !isMiniView {
                    Rectangle()
                        .opacity(0)
                        .frame(height: 20)
                }
                Spacer()
            }.offset(y: !isMiniView && isPlayerOnSide ? 20 : 0)
            
            if totalChange != 0 {
                VStack {
                    HStack {
                        if !(inverseChangeSide) {
                            Spacer()
                        }
                        Text(totalChange > 0  ? "+\(totalChange)" : "\(totalChange)")
                            .font(UIDevice.isIPhone ? .title2 : .title)
                            .foregroundColor(.white)
                            .fontWeight(.semibold)
                            .shadow(color: isMiniView ? .clear : Color("ShadowColorDarker"), radius: 3, x: 0, y: 0)
                            .padding(20)
                        if inverseChangeSide {
                            Spacer()
                        }
                    }
                    Spacer()
                }
            }
        }
    }
}
