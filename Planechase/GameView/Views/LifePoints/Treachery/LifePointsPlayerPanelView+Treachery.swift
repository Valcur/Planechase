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
        var body: some View {
            GeometryReader { geo in
                VStack {
                    if let treachery = treacheryData {
                        HStack {
                            Text(treachery.isRoleRevealed ? "" : "Scan to see your role")
                                .headline()
                            Spacer()
                            Button(action: {
                                treacheryData!.isRoleRevealed.toggle()
                            }, label: {
                                Text(treachery.isRoleRevealed ? "Hide" : "Reveal")
                                    .buttonLabel()
                            })
                        }.padding(.horizontal, 5)
                        ZStack {
                            if treachery.isRoleRevealed {
                                if let image = treachery.cardImage {
                                    /*ZStack {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: geo.size.height * 2)
                                    }.frame(height: geo.size.height, alignment: .bottom).clipped()*/
                                    ScrollView(.vertical) {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(maxWidth: geo.size.height)
                                            .cornerRadius(geo.size.height / 10)
                                    }
                                }
                            } else {
                                Image(uiImage: treachery.QRCode)
                                    .interpolation(.none)
                                    .resizable()
                                    .scaledToFit()
                                    .padding(.horizontal, 45)
                            }
                        }
                    }
                    Spacer()
                }.background(Color.black)
            }
        }
    }
    
    struct TreacheryCardView: View {
        @State private var cardImage: UIImage? = nil
        @Binding var player: PlayerProfile
        private let croppingGradient = Gradient(colors: [Color.black, Color.black, Color.black, Color.black, Color.black, Color.black, Color.black.opacity(0), Color.black.opacity(0)])
        
        var body: some View {
            GeometryReader { geo in
                HStack {
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
                        .offset(x: -geo.size.height / 4)
                    }
                    Spacer()
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
