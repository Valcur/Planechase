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
        GeometryReader { geo in
            ZStack {
                GradientView(gradientId: planechaseVM.gradientId)
                
                VStack(spacing: 8) {
                    // MARK: Top bar
                    HStack {
                        Button(action: {
                            contentManagerVM.downloadPlanechaseCardsFromScryfall()
                        }, label: {
                            Text("collection_scryfall".translate())
                                .textButtonLabel()
                        })
                        
                        ImportButton()
                        
                        Spacer()
                        
                        Text(contentManagerVM.selectedDeck.name).headline().padding(.trailing, 20)
                        
                        Text("\("collection_deckSize".translate()) : \(contentManagerVM.selectedCardsInCollection)/\(contentManagerVM.cardCollection.count)")
                            .headline()
                        
                        DeckSelection()
                    }.padding(.horizontal, 15).padding(.top, 5).iPhoneScaler(width: geo.size.width, height: 40)
                    
                    // MARK: Bottom bar
                    HStack {
                        Text("collection_howToUse".translate())
                            .headline()                       .fixedSize(horizontal: false, vertical: true).padding(5)
                        
                        Spacer()
                        
                        HStack {
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    contentManagerVM.selectAll()
                                }
                            }, label: {
                                Text("collection_selectAll".translate()).textButtonLabel()
                            })
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    contentManagerVM.unselectAll()
                                }
                            }, label: {
                                Text("collection_unselectAll").textButtonLabel()
                            })
                        }.padding(.trailing, 20)
                        
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
                    }.padding(.horizontal, 15).iPhoneScaler(width: geo.size.width, height: 40)
                    
                    ScrollView {
                        LazyVGrid(columns: smallGridModEnable ? smallGridItemLayout : gridItemLayout, spacing: 20) {
                            ForEach(contentManagerVM.cardCollection, id: \.id) { card in
                                CardView(card: card)
                                    .scaleEffect(smallGridModEnable ? 0.7 : 1)
                                    .frame(height: smallGridModEnable ? CardSizes.contentManager.height * 0.7 : CardSizes.contentManager.height)
                            }
                        }.padding(.vertical, 10).padding(.vertical, 5)
                        if contentManagerVM.cardCollection.count == 0 {
                            EmptyCardCollectionInfo()
                        }
                    }.frame(width: geo.size.width)
                }
                
                ContentManagerInfoView()
                    .position(x: geo.size.width / 2, y: geo.size.height + 50)
            }
        }
    }
    
    struct DeckSelection: View {
        @EnvironmentObject var planechaseVM: PlanechaseViewModel
        @EnvironmentObject var contentManagerVM: ContentManagerViewModel
        @State var deckSelected: Int = 0
        
        var body: some View {
            HStack {
                if !planechaseVM.isPremium {
                    Image(systemName: "crown.fill")
                        .font(.title)
                        .foregroundColor(.white)
                }
                Picker("collection_SelectDeck".translate(), selection: $deckSelected) {
                    if planechaseVM.isPremium {
                        ForEach(contentManagerVM.decks, id: \.deckId) { deck in
                            Text(deck.name).tag(deck.deckId)
                        }
                    } else {
                        Text(contentManagerVM.decks[0].name).tag(contentManagerVM.decks[0].deckId)
                    }
                }.pickerStyle(.menu).font(.subheadline).buttonLabel().opacity(planechaseVM.isPremium ? 1 : 0.6).frame(width: 140)
                .onChange(of: deckSelected) { newValue in
                    contentManagerVM.changeSelectedDeck(newDeckId: newValue)
                }
                .onAppear() {
                    deckSelected = contentManagerVM.selectedDeckId
                }
            }
        }
    }
            
    struct EmptyCardCollectionInfo: View {
        var body: some View {
            VStack {
                Text("collection_emptyCollection1".translate()).headline().padding(10)
                Text("collection_emptyCollection2".translate()).headline().frame(width: 300)
                Text("collection_emptyCollection3".translate()).headline().frame(width: 300)
            }.padding(.vertical, UIDevice.isIPad ? 100 : 10)
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
                Text("collection_import".translate())
                    .textButtonLabel()
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
                RoundedRectangle(cornerRadius: CardSizes.contentManager.cornerRadius + CardSizes.selectionBorderAdditionalCornerRadius)
                    .stroke(card.state == .selected ? .white : .clear, lineWidth: 4)
            )
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.3)) {
                    if card.state == .selected {
                        card.state = .showed
                        contentManagerVM.removeFromDeck(card)
                    } else {
                        card.state = .selected
                        contentManagerVM.addToDeck(card)
                    }
                    card.objectWillChange.send()
                }
            }
            .onLongPressGesture(minimumDuration: 0.5) {
                showingDeleteAlert = true
            }
            .alert(isPresented: $showingDeleteAlert) {
                Alert(
                    title: Text("collection_delete_title".translate()),
                    message: Text("collection_delete_content".translate()),
                    primaryButton: .destructive(Text("delete".translate())) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            contentManagerVM.removeCardFromCollection(card)
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
    
    struct ContentManagerInfoView: View {
        @EnvironmentObject var contentVM: ContentManagerViewModel
        
        var text: String {
            return "collection_empty_bubble".translate()
        }
        var showInfoView: Bool {
            return contentVM.cardCollection.count > 0 && contentVM.selectedDeck.deckCardIds.count == 0
        }
        
        var body: some View {
            Text(text).textButtonLabel(style: .secondary)
                .offset(y: showInfoView ? -80 : 0)
                .scaleEffect(1.2)
        }
    }
}

struct ContentManagerView_Previews: PreviewProvider {
    static var previews: some View {
        ContentManagerView()
            .environmentObject(ContentManagerViewModel())
    }
}
