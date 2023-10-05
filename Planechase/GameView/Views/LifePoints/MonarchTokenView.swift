//
//  MonarchTokenView.swift
//  Planechase
//
//  Created by Loic D on 05/10/2023.
//

import SwiftUI

struct MonarchTokenView: View {
    @Binding var lifepointHasBeenUsedToggler: Bool
    @State var isDragging = false
    @State private var offset = CGSize.zero
    @State private var newset = CGSize.zero
    @State var reverseCrown = false
    let blurEffect: UIBlurEffect.Style = .systemThinMaterialDark
    
    var body: some View {
        ZStack {
            VisualEffectView(effect: UIBlurEffect(style: blurEffect))
            Image(systemName: "crown.fill")
                .resizable()
                .scaledToFill()
                .foregroundColor(.white)
                .padding(25)
        }
        .frame(width: 80, height: 80)
        .cornerRadius(40)
        .rotationEffect(.degrees(reverseCrown ? 180 : 0))
        .shadowed()
        .offset(x: offset.width, y: offset.height)
        .gesture(
            DragGesture()
                .onChanged { g in
                    offset = CGSize(width: g.translation.width + newset.width, height: g.translation.height + newset.height)
                    withAnimation(.easeInOut(duration: 0.3)) {
                        reverseCrown = offset.height <= 0
                    }
                    lifepointHasBeenUsedToggler.toggle()
                }
                .onEnded { _ in
                    newset = offset
                }
        )
    }
}
