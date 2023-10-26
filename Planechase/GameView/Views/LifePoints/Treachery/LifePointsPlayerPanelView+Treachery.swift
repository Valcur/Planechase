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
                            if let image = treachery.cardImage {
                                ScrollView(.vertical) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(maxWidth: geo.size.height)
                                        .cornerRadius(geo.size.height / 10)
                                        .onTapGesture {  }
                                        .onLongPressGesture(minimumDuration: 1, perform: {
                                            treacheryData!.isRoleRevealed.toggle()
                                            lifepointHasBeenUsedToggler.toggle()
                                        })
                                }
                            }
                        } else {
                            Image(uiImage: treachery.QRCode)
                                .interpolation(.none)
                                .resizable()
                                .scaledToFit()
                                .padding(.horizontal, 45)
                                .padding(.top, 45)
                                .onLongPressGesture(minimumDuration: 1, perform: {
                                    treacheryData!.isRoleRevealed.toggle()
                                    lifepointHasBeenUsedToggler.toggle()
                                })
                        }
                        VStack {
                            HStack(alignment: .top, spacing: 10) {
                                Spacer().frame(width: 50)
                                Spacer()
                                VStack {
                                    Text(treachery.isRoleRevealed ? "" : "Scan to see your role")
                                        .font(.footnote)
                                        .foregroundColor(.white)
                                    Text(treachery.isRoleRevealed ? "" : "Hold to reveal/Hide")
                                        .font(.footnote)
                                        .foregroundColor(.white)
                                }.padding(.top, 5)
                                Spacer()
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
        @State private var cardImage: UIImage? = nil
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
                                if let image = cardImage {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFit()
                                }
                            } else {
                                Image("TreacheryCardBack")
                                    .resizable()
                                    .scaledToFit()
                                    
                            }
                        }.cornerRadius(CardSizes.cornerRadiusForWidth(geo.size.width) / 1.8)
                        /*.mask(
                            LinearGradient(gradient: croppingGradient, startPoint: .leading, endPoint: .trailing)
                        )*/
                        .offset(x: (geo.size.height / 4) * (putCardOnTheRight ? 1 : -1))
                    }
                    if !putCardOnTheRight {
                        Spacer()
                    }
                }
                .onAppear() {
                    loadCardImage()
                }
            }.allowsHitTesting(false)
        }
        
        func loadCardImage() {
            guard let treacheryData = player.treachery else { return }
            if treacheryData.cardImage == nil {
                print("loading")
                guard let url = URL(string: treacheryData.cardImageUrl) else { return }
                
                URLSession.shared.dataTask(with: url) { data, response, error in
                    guard let data = data, error == nil else {
                        return
                    }
                    
                    DispatchQueue.main.async {
                        self.cardImage = UIImage(data: data)
                        player.treachery?.cardImage = self.cardImage
                    }
                }.resume()
            } else {
                print("already loaded")
                cardImage = treacheryData.cardImage
            }
        }
    }
}
