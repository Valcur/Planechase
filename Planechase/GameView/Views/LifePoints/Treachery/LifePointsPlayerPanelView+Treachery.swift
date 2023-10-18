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
                            Text("Scan to see your role")
                                .headline()
                            Spacer()
                            Button(action: {
                                treacheryData!.isRoleRevealed.toggle()
                            }, label: {
                                Text(treacheryData!.isRoleRevealed ? "Hide" : "Reveal")
                                    .buttonLabel()
                            })
                        }
                        HStack {
                            Spacer()
                            if treachery.isRoleRevealed {
                                if let image = treachery.cardImage {
                                    ZStack {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: geo.size.height * 2)
                                    }.frame(height: geo.size.height, alignment: .bottom).clipped()
                                }
                            } else {
                                Image(uiImage: treachery.QRCode)
                                    .interpolation(.none)
                                    .resizable()
                                    .scaledToFit()
                            }
                            Spacer()
                        }
                    }
                }.background(Color.white)
            }
        }
    }
    
    struct TreacheryCardView: View {
        @State private var cardImage: UIImage? = nil
        @Binding var player: PlayerProfile
        
        var body: some View {
            GeometryReader { geo in
                HStack {
                    if let treachery = player.treachery {
                        if treachery.isRoleRevealed {
                            if let image = cardImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .cornerRadius(CardSizes.cornerRadiusForWidth(geo.size.width) / 2)
                            }
                        } else {
                            Image("TreacheryCardBack")
                                .resizable()
                                .scaledToFit()
                                .cornerRadius(CardSizes.cornerRadiusForWidth(geo.size.width) / 2)
                        }
                    }
                    Spacer()
                }
                .onAppear() {
                    loadCardImage()
                }
            }
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
