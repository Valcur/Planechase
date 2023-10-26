//
//  CircularButtonView.swift
//  Planechase
//
//  Created by Loic D on 25/10/2023.
//

import SwiftUI

struct CircularButtonView: View {
    @State var showMenu: Bool = false
    let spacing: CGFloat = 80
    let buttons: [AnyView]
    @Binding var lifepointHasBeenUsedToggler: Bool
    
    var body: some View {
        ZStack {
            // Hidden Buttons
            buttons[0].offset(x: showMenu ? -spacing : 0)
            
            buttons[1].offset(x: showMenu ? -spacing : 0, y: showMenu ? -spacing : 0)
            
            buttons[2].offset(y: showMenu ? -spacing : 0)
            
            
            // Enable
            Button(action: {
                withAnimation(.spring()) {
                    showMenu.toggle()
                }
                lifepointHasBeenUsedToggler.toggle()
            }, label: {
                Image(systemName: showMenu ? "chevron.down.circle" : "chevron.up.circle")
                    .imageButtonLabel(style: .secondary)
            })
        }
    }
}
