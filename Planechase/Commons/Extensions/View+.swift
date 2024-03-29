//
//  View+.swift
//  Planechase
//
//  Created by Loic D on 12/12/2023.
//

import SwiftUI

extension View {
    func scrollablePanel() -> some View {
        ScrollView(.vertical) {
            self.padding(15)
        }.padding(5).frame(maxWidth: .infinity)
    }
    
    func gradientBackground(gradientId: Int) -> some View {
        ZStack {
            GradientView(gradientId: gradientId)
            self
        }
    }
    
    func shadowed(radius: CGFloat = 4, y: CGFloat = 4, color: Color = Color("ShadowColor")) -> some View {
        self
            .shadow(color: color, radius: radius, x: 0, y: y)
    }
    
    func blurredBackground(style: ViewStyle = .primary, cornerRadius: CGFloat = 15) -> some View {
        self
            .background( ZStack {
                if style == .primary {
                    VisualEffectView(effect: UIBlurEffect(style: .systemMaterialDark))
                        .cornerRadius(cornerRadius)
                        .shadowed(color: Color("BlurredShadowColor"))
                } else if style == .secondary {
                    Color.black
                        .cornerRadius(cornerRadius)
                        .shadowed(color: Color("BlurredShadowColor"))
                }
            })
    }
    
    func blackTransparentBackground(cornerRadius: CGFloat = 15) -> some View {
        self
            .background(Color.black.cornerRadius(cornerRadius).opacity(0.5))
    }
    
    func buttonLabel(style: ViewStyle = .primary) -> some View {
        self
            .foregroundColor(.white)
            .padding()
            .blurredBackground(style: style)
            .padding(5)
    }
    
    func iPhoneScaler(width: CGFloat, height: CGFloat, scaleEffect: CGFloat = 0.8, anchor: UnitPoint = .center) -> some View {
        ZStack {
            if UIDevice.isIPhone {
                self
                    .frame(width: width / scaleEffect)
                    .scaleEffect(scaleEffect, anchor: anchor)
                    .frame(height: height)
                    .frame(width: width)
            } else {
                self
            }
        }
    }
    
    func iPhoneScaler_widthOnly(width: CGFloat, scaleEffect: CGFloat = 0.8, anchor: UnitPoint = .center) -> some View {
        ZStack {
            if UIDevice.isIPhone {
                self
                    .frame(width: width / scaleEffect)
                    .scaleEffect(scaleEffect, anchor: anchor)
                    .frame(width: width)
            } else {
                self
            }
        }
    }
    
    func premiumRestricted(_ isPremium: Bool) -> some View {
        self.opacity(isPremium ? 1 : 0.6).disabled(!isPremium)
    }
    
    func premiumCrowned(_ isPremium: Bool) -> some View {
        HStack {
            if !isPremium {
                Image(systemName: "crown.fill")
                    .font(.title)
                    .foregroundColor(.white)
            }
            self
        }
    }
    
    // TODO: Doublon avec buttonlabel ???
    func genericButtonLabel(style: ViewStyle = .primary) -> some View {
        self
            .foregroundColor(.white)
            .padding()
            .blurredBackground(style: style)
            .padding(5)
    }
}
