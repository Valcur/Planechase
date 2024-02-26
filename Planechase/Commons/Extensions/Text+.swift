//
//  Text+.swift
//  Planechase
//
//  Created by Loic D on 12/12/2023.
//

import SwiftUI

extension Text {
    func textButtonLabel(style: ViewStyle = .primary) -> some View {
        ZStack {
            if style == .noBackground {
                self
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.white, lineWidth: 2)
                    )
                    .padding(5)
            } else {
                self
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding()
                    .blurredBackground(style: style)
                    .padding(5)
            }
        }
    }
    
    func textButtonLabel(systemName: String, style: ViewStyle = .primary) -> some View {
        HStack {
            Image(systemName: systemName)
                .font(.subheadline)
                .foregroundColor(.white)
            
            self
                .font(.subheadline)
                .foregroundColor(.white)
        }
        .padding()
        .blurredBackground(style: style)
        .padding(5)
    }
    
    func largeTitle() -> some View {
        self
            .font(UIDevice.isIPhone ? .title : .largeTitle)
            .foregroundColor(.white)
            .fontWeight(.bold)
    }
    
    func title() -> some View {
        self
            .font(.title)
            .foregroundColor(.white)
            .fontWeight(.bold)
    }
    
    func headline() -> some View {
        self
            .font(.subheadline)
            .foregroundColor(.white)
            .fixedSize(horizontal: false, vertical: true)
            //.fontWeight(.bold)
    }
    
    func underlinedLink() -> some View {
        self
            .font(.headline)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .underline()
    }
}

enum ViewStyle {
    case primary
    case secondary
    case noBackground
}
