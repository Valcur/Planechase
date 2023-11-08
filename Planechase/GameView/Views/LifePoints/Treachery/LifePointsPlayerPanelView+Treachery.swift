//
//  LifePointsPlayerPanelView+Treachery.swift
//  Planechase
//
//  Created by Loic D on 18/10/2023.
//

import SwiftUI

extension LifePointsPlayerPanelView {
    struct TreacheryPanelView: View {
        @Binding var treacheryData: TreacheryPlayer?
        @Binding var showPanel: Bool
        @Binding var lifepointHasBeenUsedToggler: Bool
        let isOnTheOppositeSide: Bool
        
        var body: some View {
            GeometryReader { geo in
                if let treachery = treacheryData {
                    ZStack {
                        if treachery.isRoleRevealed {
                            ScrollView(.vertical, showsIndicators: false) {
                                ScrollViewReader { value in
                                    Image(treachery.cardImageName)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(maxWidth: geo.size.height * 1.2)
                                        .cornerRadius(CardSizes.classic_cornerRadiusForHeight(geo.size.height))
                                        .onTapGesture {  }
                                        .onLongPressGesture(minimumDuration: 1, perform: {
                                            treacheryData!.isRoleRevealed.toggle()
                                            lifepointHasBeenUsedToggler.toggle()
                                        })
                                        .id(0)
                                        .onAppear {
                                            value.scrollTo(0, anchor: .bottom)
                                        }
                                }
                            }
                        } else {
                            Image(uiImage: treachery.QRCode)
                                .interpolation(.none)
                                .resizable()
                                .scaledToFit()
                                .padding(.horizontal, 45)
                                .padding(.top, 45)
                                .padding(.bottom, UIDevice.isIPhone ? 10 : 0)
                                .onLongPressGesture(minimumDuration: 1, perform: {
                                    treacheryData!.isRoleRevealed.toggle()
                                    lifepointHasBeenUsedToggler.toggle()
                                })
                        }
                        VStack {
                            HStack(alignment: .top, spacing: 10) {
                                Spacer().frame(width: 50)
                                VStack {
                                    Text(treachery.isRoleRevealed ? "" : "Scan to see your role")
                                        .font(.footnote)
                                        .foregroundColor(.white)
                                    Text(treachery.isRoleRevealed ? "" : "Hold to reveal/Hide")
                                        .font(.footnote)
                                        .foregroundColor(.white)
                                }.frame(maxWidth: .infinity).padding(.top, 5)
                                Button(action: {
                                    showPanel = false
                                    lifepointHasBeenUsedToggler.toggle()
                                }, label: {
                                    Image(systemName: "xmark")
                                        .resizable()
                                        .frame(width: 15, height: 15)
                                        .genericButtonLabel()
                                }).frame(width: 50)
                            }.padding(.horizontal, 2).environment(\.layoutDirection, isOnTheOppositeSide ? .rightToLeft : .leftToRight)
                            Spacer()
                        }
                    }.background(Color.black)
                }
            }
        }
    }
    
    struct TreacheryCardView: View {
        @Binding var player: PlayerProfile
        let putCardOnTheRight: Bool
        private let croppingGradient = Gradient(colors: [Color.black, Color.black, Color.black, Color.black, Color.black, Color.black, Color.black.opacity(0), Color.black.opacity(0)])
        
        var body: some View {
            GeometryReader { geo in
                HStack {
                    if putCardOnTheRight {
                        Spacer()
                    }
                    if let treachery = player.treachery {
                        ZStack {
                            if treachery.isRoleRevealed {
                                Image(treachery.cardImageName)
                                    .resizable()
                                    .scaledToFit()
                            } else {
                                Image("TreacheryCardBack")
                                    .resizable()
                                    .scaledToFit()
                                    
                            }
                        }.cornerRadius(CardSizes.classic_cornerRadiusForHeight(geo.size.height))
                        /*.mask(
                            LinearGradient(gradient: croppingGradient, startPoint: .leading, endPoint: .trailing)
                        )*/
                        .offset(x: (geo.size.height / 3) * (putCardOnTheRight ? 1 : -1))
                    }
                    if !putCardOnTheRight {
                        Spacer()
                    }
                }
            }.allowsHitTesting(false)
        }
    }
}
