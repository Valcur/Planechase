//
//  Image+.swift
//  Planechase
//
//  Created by Loic D on 12/12/2023.
//

import SwiftUI

extension Image {
    func imageButtonLabel(style: ViewStyle = .primary, customSize: CGFloat = 27) -> some View {
        self
            .resizable()
            .frame(width: customSize, height: customSize)
            .foregroundColor(.white)
            .padding()
            .frame(width: style == .noBackground ? 40 : 60, height: style == .noBackground ? 40 : 60)
            .blurredBackground(style: style)
            .padding(5)
    }
}
