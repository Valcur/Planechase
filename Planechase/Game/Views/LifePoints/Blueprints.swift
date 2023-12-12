//
//  Blueprints.swift
//  Planechase
//
//  Created by Loic D on 24/05/2023.
//

import SwiftUI

struct EvenBlueprint: View {
    @EnvironmentObject var lifePointsViewModel: LifePointsViewModel
    let row1: AnyView
    let row2: AnyView
    
    var body: some View {
        VStack(spacing: 0) {
            row1.rotationEffect(.degrees(180))
            row2
        }
    }
}

struct UnevenBlueprint: View {
    @EnvironmentObject var lifePointsViewModel: LifePointsViewModel
    let row1: AnyView
    let row2: AnyView
    let sideElement: AnyView

    var unevenScalerDivider: CGFloat {
        let nbrOfPlayer = lifePointsViewModel.numberOfPlayer
        if nbrOfPlayer == 5 {
            return UIDevice.isIPhone ? 3.5 : 3.25
        } else  if nbrOfPlayer == 7 {
            return UIDevice.isIPhone ? 4 : 4
        }
        return UIDevice.isIPhone ? 2.8 : 2.8
    }
    
    var body: some View {
        GeometryReader { geo in
            HStack(spacing: 0) {
                VStack(spacing: 0) {
                    row1.rotationEffect(.degrees(180))
                    row2
                }
                sideElement
                    .frame(width: geo.size.height, height: geo.size.width / unevenScalerDivider).clipped()
                    .rotationEffect(.degrees(-90))
                    .frame(width: geo.size.width / unevenScalerDivider)
            }
        }
    }
}
