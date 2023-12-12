//
//  FullScreenView.swift
//  LifeCounter
//
//  Created by Loic D on 13/11/2023.
//

import SwiftUI

struct FullScreenView: View {
    @Binding var fullscreenView: FullscreenView?
    var body: some View {
        if let myFullscreenView = fullscreenView {
            ZStack {
                Color.black.opacity(0.6)
                    .onTapGesture() {
                        fullscreenView = nil
                    }
                GeometryReader { geo in
                    ZStack(alignment: .topTrailing) {
                        Color.black
                        myFullscreenView.view
                            .frame(width: myFullscreenView.orientation == .side ? geo.size.height : geo.size.width)
                            .frame(height: myFullscreenView.orientation == .side ? geo.size.width : geo.size.height)
                            .rotationEffect(Angle.degrees(myFullscreenView.orientation == .opposite ? 180 : (myFullscreenView.orientation == .side ? -90 : 0)), anchor: myFullscreenView.orientation == .side ? .topTrailing : .center)
                            .offset(x: myFullscreenView.orientation == .side ? -geo.size.width : 0)
                    }
                }
                .cornerRadius(15)
                .shadowed()
                .padding(.vertical, 50)
                .padding(.leading, 180)
                .padding(.trailing, 100)
            }
        }
    }
}

struct FullscreenView {
    var view: AnyView
    var orientation: ViewOrientation
}

enum ViewOrientation {
    case classic
    case opposite
    case side
}

