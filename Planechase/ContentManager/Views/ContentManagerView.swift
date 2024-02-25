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
    @State private var showingFilterSheet = false
    @State var currentIndex: Int = 0
    @State var isFullscreen: Bool = false
    @State private var showingDeleteAlert = false
    private var gridItemLayout: [GridItem]  {
        Array(repeating: GridItem(.flexible()), count: 2)
    }
    private var smallGridItemLayout: [GridItem]  {
        Array(repeating: GridItem(.flexible()), count: 3)
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                GradientView(gradientId: planechaseVM.gradientId)
                
                if isFullscreen && false {
                    CardImageBackground(card: contentManagerVM.filteredCardCollection[currentIndex], blurRadius: 30)
                    
                    // TODO: enlver geometry reader
                    GeometryReader { carouselGeo in
                        CardCarouselView(index: $currentIndex, items: contentManagerVM.filteredCardCollection, cardWidth: CardSizes.widthtForHeight(carouselGeo.size.height), spacing: UIDevice.isIPhone ? 0 : -100, id: \.id) {
                            card, size in
                            CardView(card: card, width: size.width, height: size.height)
                        }//.padding(.horizontal, -15)
                    }.padding(.top, UIDevice.isIPhone ? 12 : 90).padding(.bottom, UIDevice.isIPhone ? 12 : 50)
                    
                    Text("\(currentIndex + 1)/\(contentManagerVM.filteredCardCollection.count)")
                        .title()
                        .frame(width: 200, alignment: .leading)
                        .position(x: 150, y: UIDevice.isIPhone ? 30 : 50)
                        .scaleEffect(UIDevice.isIPhone ? 0.7 : 1, anchor: .topLeading)

                    Button(action: {
                        isFullscreen = false
                    }, label: {
                        Image(systemName: "arrow.up.left.and.arrow.down.right")
                            .font(.title)
                            .foregroundColor(.white)
                    }).position(x: geo.size.width - 50, y: UIDevice.isIPhone ? 30 : 50)
                        .scaleEffect(UIDevice.isIPhone ? 0.7 : 1, anchor: .topTrailing)
                } else {
                    VStack(spacing: 0) {
                        VStack(spacing: UIDevice.isIPhone ? 2 : 8) {
                            // MARK: Top bar
                            HStack {
                                Button(action: {
                                    contentManagerVM.downloadPlanechaseCardsFromScryfall()
                                }, label: {
                                    Text("collection_scryfall".translate())
                                        .textButtonLabel(systemName: "square.and.arrow.down", style: .secondary)
                                })
                                
                                ImportButton()
                                
                                Spacer()
                                
                                Text("\("collection_deckSize".translate()) : \(contentManagerVM.selectedCardsInCollection)/\(contentManagerVM.cardCollection.count)")
                                    .headline()
                                
                                DeckSelection(selectedDeck: contentManagerVM.selectedDeckId)
                            }.padding(.horizontal, 15).padding(.top, 5).iPhoneScaler(width: geo.size.width, height: 44)
                            
                            // MARK: Bottom bar
                            HStack() {
                                Button(action: {
                                    showingFilterSheet.toggle()
                                }, label: {
                                    Image(systemName: "slider.horizontal.3")
                                        .font(.title)
                                        .foregroundColor(.white)
                                })
                                .sheet(isPresented: $showingFilterSheet) {
                                    FilterSheet()
                                }
                                
                                Rectangle().frame(width: 2, height: 40).foregroundColor(.white)
                                
                                BottomRow(smallGridModEnable: $smallGridModEnable, isFullscreen: $isFullscreen)
                            }.padding(.horizontal, 15).iPhoneScaler(width: geo.size.width, height: 44)
                        }.background(Color.black.opacity(0.5).ignoresSafeArea())
                        GeometryReader { scrollGeo in
                            ScrollView {
                                LazyVGrid(columns: smallGridModEnable ? smallGridItemLayout : gridItemLayout, spacing: 20) {
                                    ForEach(contentManagerVM.filteredCardCollection, id: \.id) { card in
                                        CardView(card: card, width: cardWidth(scrollViewWidth: scrollGeo.size.width), height: cardHeight(scrollViewWidth: scrollGeo.size.width))
                                            .frame(width: cardWidth(scrollViewWidth: scrollGeo.size.width), height: cardHeight(scrollViewWidth: scrollGeo.size.width))
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
                                                if let newIndex = contentManagerVM.filteredCardCollection.firstIndex(of: card) {
                                                    isFullscreen = true
                                                    currentIndex = newIndex
                                                }
                                            }
                                    }
                                }.padding(.vertical, 10).padding(.vertical, 5).padding(.horizontal, 7)
                                if contentManagerVM.cardCollection.count == 0 {
                                    EmptyCardCollectionInfo()
                                }
                            }
                        }
                    }.fullScreenCover(isPresented: $isFullscreen) {
                        ZStack {
                            Text("\(currentIndex + 1)/\(contentManagerVM.filteredCardCollection.count)")
                                .title()
                                .frame(width: 200, alignment: .leading)
                                .position(x: 150, y: UIDevice.isIPhone ? 30 : 50)
                                .scaleEffect(UIDevice.isIPhone ? 0.7 : 1, anchor: .topLeading)

                            Button(action: {
                                isFullscreen = false
                            }, label: {
                                Image(systemName: "arrow.down.right.and.arrow.up.left")
                                    .font(.title)
                                    .foregroundColor(.white)
                            }).position(x: geo.size.width - 50, y: UIDevice.isIPhone ? 30 : 50)
                            
                            let selectedCard = contentManagerVM.filteredCardCollection[currentIndex]
                            Button(action: {
                                if selectedCard.state == .selected {
                                    selectedCard.state = .showed
                                    contentManagerVM.removeFromDeck(selectedCard)
                                } else {
                                    selectedCard.state = .selected
                                    contentManagerVM.addToDeck(selectedCard)
                                }
                                selectedCard.objectWillChange.send()
                            }, label: {
                                Image(systemName: selectedCard.state == .selected ? "checkmark.circle.fill" : "checkmark.circle")
                                    .imageButtonLabel()
                            }).position(x: geo.size.width - 50, y: geo.size.height - (UIDevice.isIPhone ? -10 : 50))
                            
                            Button(action: {
                                showingDeleteAlert = true
                            }, label: {
                                Image(systemName: "trash.circle")
                                    .imageButtonLabel()
                            }).position(x: 50, y: geo.size.height - (UIDevice.isIPhone ? -10 : 50))
                                .alert(isPresented: $showingDeleteAlert) {
                                    Alert(
                                        title: Text("collection_delete_title".translate()),
                                        message: Text("collection_delete_content".translate()),
                                        primaryButton: .destructive(Text("delete".translate())) {
                                            withAnimation(.easeInOut(duration: 0.3)) {
                                                contentManagerVM.removeCardFromCollection(selectedCard)
                                            }
                                        },
                                        secondaryButton: .cancel()
                                    )
                                }
                        }.statusBar(hidden: true)
                            .background(
                                ZStack {
                                    CardImageBackground(card: contentManagerVM.filteredCardCollection[currentIndex], blurRadius: 30)
                                    
                                    // TODO: enlver geometry reader
                                    GeometryReader { carouselGeo in
                                        CardCarouselView(index: $currentIndex, items: contentManagerVM.filteredCardCollection, cardWidth: CardSizes.widthtForHeight(carouselGeo.size.height), spacing: UIDevice.isIPhone ? 0 : -100, id: \.id) {
                                            card, size in
                                            ZStack {
                                                Color.black.opacity(0.000001)
                                                CardView(card: card, width: size.width, height: CardSizes.heightForWidth(size.width))
                                                    .allowsHitTesting(false)
                                            }
                                        }
                                    }.padding(.top, UIDevice.isIPhone ? 12 : 90).padding(.bottom, UIDevice.isIPhone ? 12 : 50)
                                }.ignoresSafeArea()
                            )
                    }
                }
                
                ContentManagerInfoView()
                    .position(x: geo.size.width / 2, y: geo.size.height + 50)
            }
        }
        .onAppear() {
            contentManagerVM.importedCardsToChangeType = []
        }
        .onChange(of: contentManagerVM.filteredCardCollection) { _ in
            currentIndex = 0
        }
    }
    
    private func cardWidth(scrollViewWidth: CGFloat) -> CGFloat {
        return ((scrollViewWidth - 14) / (smallGridModEnable ? 3 : 2)) * 0.94
    }
    
    private func cardHeight(scrollViewWidth: CGFloat) -> CGFloat {
        return CardSizes.heightForWidth(cardWidth(scrollViewWidth: scrollViewWidth))
    }
    
    struct DeckSelection: View {
        @EnvironmentObject var planechaseVM: PlanechaseViewModel
        @EnvironmentObject var contentManagerVM: ContentManagerViewModel
        @State var deckSelected: Int
        @State private var showingDeckNameChange = false
        @State private var newDeckName: String = "a"
        
        init(selectedDeck: Int) {
            deckSelected = selectedDeck
        }
        
        var body: some View {
            HStack {
               if planechaseVM.isPremium {
                    if #available(iOS 15.0, *) {
                        Button(action: {
                            newDeckName = contentManagerVM.selectedDeck.name
                            withAnimation {
                                self.showingDeckNameChange.toggle()
                            }
                        }, label: {
                            Image(systemName: "pencil")
                                .font(.title)
                                .foregroundColor(.white)
                                .padding(.trailing, 0)
                        })
                        .alert("collection_rename_title".translate(), isPresented: $showingDeckNameChange) {
                            TextField("", text: $newDeckName)
                            Button("confirm".translate()) {
                                newDeckName = String(newDeckName.prefix(25))
                                contentManagerVM.decks[contentManagerVM.selectedDeckId].name = newDeckName
                                SaveManager.saveDecks(contentManagerVM.decks)
                            }
                            Button("cancel".translate(), role: .cancel) {
                                newDeckName = contentManagerVM.selectedDeck.name
                            }
                        } message: {
                            Text("collection_rename_content".translate())
                        }
                    }
                } else {
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
                }.pickerStyle(.menu).accentColor(.white).font(.subheadline).frame(height: 20).buttonLabel(style: .secondary).opacity(planechaseVM.isPremium ? 1 : 0.6).frame(width: 200)
                .onChange(of: deckSelected) { newValue in
                    withAnimation(.easeInOut(duration: 0.3)) {
                        contentManagerVM.changeSelectedDeck(newDeckId: newValue)
                        newDeckName = contentManagerVM.selectedDeck.name
                    }
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
                    .textButtonLabel(style: .secondary)
            })
            .onChange(of: inputImage) { _ in addNewImageToCollection() }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $inputImage).preferredColorScheme(.dark)
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
        @EnvironmentObject var planechaseVM: PlanechaseViewModel
        @EnvironmentObject var contentManagerVM: ContentManagerViewModel
        @ObservedObject var card: Card
        @State private var showingDeleteAlert = false
        let width: CGFloat
        let height: CGFloat
        @State var cardType: CardTypeLine = .plane
        
        var body: some View {
            ZStack(alignment: .topLeading) {
                if card.image == nil {
                    Color.black
                        .frame(width: width,
                               height: height)
                        .cornerRadius(CardSizes.cornerRadiusForWidth(width))
                        .onAppear {
                            card.cardAppears()
                            //print("i appear")
                        }
                } else {
                    Image(uiImage: card.image!)
                        .resizable()
                        .frame(width: width,
                               height: height)
                        .cornerRadius(CardSizes.cornerRadiusForWidth(width))
                }
                if card.imageURL == nil && planechaseVM.showCustomCardsTypeButtons {
                    Button(action: {
                        contentManagerVM.switchCardType(card, typeLink: $cardType)
                        if cardType == .plane {
                            cardType = .phenomenon
                        } else {
                            cardType = .plane
                        }
                    }, label: {
                        Text(cardType == .plane ? "plane".translate() : "phenomenon".translate())
                            .textButtonLabel()
                    })
                }
            }
            .onAppear() {
                cardType = card.cardType == nil ? .plane : card.cardType!
            }
            .padding(5)
            .overlay(
                RoundedRectangle(cornerRadius: CardSizes.cornerRadiusForWidth(width) + CardSizes.selectionBorderAdditionalCornerRadius)
                    .stroke(card.state == .selected ? .white : .clear, lineWidth: 4)
            )
        }
    }
    
    struct ContentManagerInfoView: View {
        @EnvironmentObject var contentVM: ContentManagerViewModel
        
        var text: String {
            return "collection_empty_bubble".translate()
        }
        var showTypeChange: Bool {
            return contentVM.importedCardsToChangeType.count > 0
        }
        var showDeckEmpty: Bool {
            return contentVM.cardCollection.count > 0 && contentVM.selectedDeck.deckCardIds.count == 0
        }
        var showInfoView: Bool {
            return showDeckEmpty || showTypeChange
        }
        
        var body: some View {
            ZStack {
                HStack {
                    Button(action: {
                        DispatchQueue.main.async {
                            contentVM.applyCardTypesChanges()
                        }
                    }, label: {
                        Text("collection_confirmTypeChange".translate()).textButtonLabel(style: .secondary)
                    })
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            contentVM.cancelCardTypeChanges()
                        }
                    }, label: {
                        Text("cancel".translate()).textButtonLabel(style: .secondary)
                    })
                }.opacity(showTypeChange ? 1 : 0)
                Text(text).textButtonLabel(style: .secondary).opacity(showDeckEmpty && !showTypeChange ? 1 : 0)
            }
                .offset(y: showInfoView ? -80 : 0)
                .scaleEffect(1.2)
                .opacity(showInfoView ? 1 : 0)
        }
    }
}

struct ContentManagerView_Previews: PreviewProvider {
    static var previews: some View {
        ContentManagerView()
            .environmentObject(ContentManagerViewModel())
    }
}
/*
extension View {
    func fullscreenTopSection(isFullscreen: Bool) -> some View {
        ZStack {
            if isFullscreen {
                self.opacity(0).frame(maxHeight: 0)
            } else {
                self
            }
        }
    }
}
*/
