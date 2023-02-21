//
//  ContentManagerView.swift
//  Planechase
//
//  Created by Loic D on 20/02/2023.
//

import SwiftUI

struct ContentManagerView: View {
    @EnvironmentObject var contentManagerVM: ContentManagerViewModel
    
    private var gridItemLayout: [GridItem]  {
        Array(repeating: .init(.adaptive(minimum: 300)), count: 4)
    }
    
    var body: some View {
        ZStack {
            GradientView(gradientId: 1)
            
            VStack {
                HStack {
                    Button(action: {
                        contentManagerVM.downloadPlanechaseCardsFromScryfall()
                    }, label: {
                        Text("Download from Scryfall")
                            .buttonLabel()
                    })
                    
                    Button(action: {

                    }, label: {
                        Text("Import")
                            .buttonLabel()
                    })
                }
                
                Text("Tap to add/remove a card from your deck. Hold to delete from your collection.")
                
                ScrollView {
                    LazyVGrid(columns: gridItemLayout, spacing: 20) {
                        ForEach(contentManagerVM.cardCollection, id: \.id) { card in
                            CardView(card: card)
                        }
                    }.padding(5)
                }
            }
        }
    }
    
    struct CardView: View {
        @EnvironmentObject var contentManagerVM: ContentManagerViewModel
        @ObservedObject var card: Card
        
        var body: some View {
            Button(action: {
                if card.state == .selected {
                    card.state = .showed
                } else {
                    card.state = .selected
                }
                withAnimation(.easeInOut(duration: 0.3)) {
                    card.objectWillChange.send()
                }
                contentManagerVM.saveCollection()
            }, label: {
                if card.image == nil {
                    Color.black
                        .frame(width: 250, height: 180)
                        .cornerRadius(15)
                        .onAppear {
                            card.cardAppears()
                        }
                } else {
                    card.image!
                        .resizable()
                        .frame(width: 250, height: 180)
                        .cornerRadius(15)
                }
            })
            .padding(5)
            .overlay(
                RoundedRectangle(cornerRadius: 19)
                    .stroke(card.state == .selected ? .white : .clear, lineWidth: 4)
            )
        }
    }
}

struct ContentManagerView_Previews: PreviewProvider {
    static var previews: some View {
        ContentManagerView()
            .environmentObject(ContentManagerViewModel())
    }
}
