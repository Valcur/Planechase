//
//  ContentManagerView.swift
//  Planechase
//
//  Created by Loic D on 20/02/2023.
//

import SwiftUI

struct ContentManagerView: View {
    @EnvironmentObject var planechaseVM: PlanechaseViewModel
    @EnvironmentObject var contentManagerVM: ContentManagerViewModel
    @State var smallGridModEnable = true
    private var gridItemLayout: [GridItem]  {
        Array(repeating: .init(.fixed(CardSizes.contentManager.width + 50)), count: 2)
    }
    private var smallGridItemLayout: [GridItem]  {
        Array(repeating: .init(.fixed(CardSizes.contentManager.width * 0.7 + 50)), count: 3)
    }
    
    var body: some View {
        ZStack {
            GradientView(gradientId: planechaseVM.gradientId)
            
            VStack(spacing: 8) {
                HStack {
                    Button(action: {
                        contentManagerVM.downloadPlanechaseCardsFromScryfall()
                    }, label: {
                        Text("Download from Scryfall")
                            .buttonLabel()
                    })
                    
                    ImportButton()
                    
                    Spacer()
                    
                    Text("Deck size : \(contentManagerVM.selectedCardsInCollection)/\(contentManagerVM.cardCollection.count)")
                        .headline()
                    
                    Spacer()
                    
                    HStack {
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                smallGridModEnable = true
                            }
                        }, label: {
                            Image(systemName: "rectangle.grid.3x2")
                                .font(.title)
                                .foregroundColor(.white)
                        }).opacity(smallGridModEnable ? 1 : 0.6)
                        
                        Text("/").font(.title).fontWeight(.light).foregroundColor(.white)
                        
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                smallGridModEnable = false
                            }
                        }, label: {
                            Image(systemName: "rectangle.grid.2x2")
                                .font(.title)
                                .foregroundColor(.white)
                        }).opacity(smallGridModEnable ? 0.6 : 1)
                    }
                }.padding(.horizontal, 15)
                
                Text("Tap to add/remove a card from your deck. Hold to delete from your collection.")
                    .headline().padding(5)
                
                ScrollView {
                    LazyVGrid(columns: smallGridModEnable ? smallGridItemLayout : gridItemLayout, spacing: 20) {
                        ForEach(contentManagerVM.cardCollection, id: \.id) { card in
                            CardView(card: card)
                                .scaleEffect(smallGridModEnable ? 0.7 : 1)
                                .frame(height: smallGridModEnable ? CardSizes.contentManager.height * 0.7 : CardSizes.contentManager.height)
                        }
                    }.padding(.vertical, 10).padding(.vertical, 5)
                }
            }
        }
    }
    
    struct ImportButton: View {
        @EnvironmentObject var contentManagerVM: ContentManagerViewModel
        @State var showingImagePicker: Bool = false
        @State private var inputImage: UIImage?
        
        var body: some View {
            Button(action: {
                showingImagePicker = true
            }, label: {
                Text("Import")
                    .buttonLabel()
            })
            .onChange(of: inputImage) { _ in addNewImageToCollection() }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $inputImage)
            }
        }
        
        func addNewImageToCollection() {
            guard let inputImage = inputImage else { return }
            withAnimation(.easeInOut(duration: 0.3)) {
                contentManagerVM.importNewImageToCollection(image: inputImage)
            }
            
        }
    }
    
    struct CardView: View {
        @EnvironmentObject var contentManagerVM: ContentManagerViewModel
        @ObservedObject var card: Card
        @State private var showingDeleteAlert = false
        
        var body: some View {
            ZStack {
                if card.image == nil {
                    Color.black
                        .frame(width: CardSizes.contentManager.width,
                               height: CardSizes.contentManager.height)
                        .cornerRadius(CardSizes.contentManager.cornerRadius)
                        .onAppear {
                            card.cardAppears()
                        }
                } else {
                    Image(uiImage: card.image!)
                        .resizable()
                        .frame(width: CardSizes.contentManager.width,
                               height: CardSizes.contentManager.height)
                        .cornerRadius(CardSizes.contentManager.cornerRadius)
                }
            }
            .padding(5)
            .overlay(
                RoundedRectangle(cornerRadius: CardSizes.contentManager.cornerRadius + 4)
                    .stroke(card.state == .selected ? .white : .clear, lineWidth: 4)
            )
            .onTapGesture {
                if card.state == .selected {
                    card.state = .showed
                } else {
                    card.state = .selected
                }
                withAnimation(.easeInOut(duration: 0.3)) {
                    card.objectWillChange.send()
                }
                contentManagerVM.applyChangesToCollection()
            }
            .onLongPressGesture(minimumDuration: 0.5) {
                showingDeleteAlert = true
            }
            .alert(isPresented: $showingDeleteAlert) {
                Alert(
                    title: Text("Are you sure you want to delete this ?"),
                    message: Text("There is no undo"),
                    primaryButton: .destructive(Text("Delete")) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            contentManagerVM.removeCardFromCollection(card)
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
}

struct ContentManagerView_Previews: PreviewProvider {
    static var previews: some View {
        ContentManagerView()
            .environmentObject(ContentManagerViewModel())
    }
}
