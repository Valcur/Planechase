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
                
                VStack(spacing: UIDevice.isIPhone ? 2 : 8) {
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
                        
                        Text("\("collection_deckSize".translate()) : \(contentManagerVM.selectedCardsInCollection)/\(contentManagerVM.cardCollection.count)")
                            .headline()
                        
                        DeckSelection()
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
                        
                        BottomRow(smallGridModEnable: $smallGridModEnable)
                    }.padding(.horizontal, 15).iPhoneScaler(width: geo.size.width, height: 44)
                    
                    GeometryReader { scrollGeo in
                        ScrollView {
                            LazyVGrid(columns: smallGridModEnable ? smallGridItemLayout : gridItemLayout, spacing: 20) {
                                ForEach(contentManagerVM.filteredCardCollection, id: \.id) { card in
                                    CardView(card: card, width: cardWidth(scrollViewWidth: scrollGeo.size.width), height: cardHeight(scrollViewWidth: scrollGeo.size.width))
                                        .frame(width: cardWidth(scrollViewWidth: scrollGeo.size.width), height: cardHeight(scrollViewWidth: scrollGeo.size.width))
                                }
                            }.padding(.vertical, 10).padding(.vertical, 5).padding(.horizontal, 7)
                            if contentManagerVM.cardCollection.count == 0 {
                                EmptyCardCollectionInfo()
                            }
                        }
                    }
                }
                
                ContentManagerInfoView()
                    .position(x: geo.size.width / 2, y: geo.size.height + 50)
            }
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
        @State var deckSelected: Int = 0
        @State private var showingDeckNameChange = false
        @State private var newDeckName: String = ""
        
        var body: some View {
            HStack {
                if planechaseVM.isPremium {
                    if #available(iOS 15.0, *) {
                        Button(action: {
                            withAnimation {
                                self.showingDeckNameChange.toggle()
                            }
                        }, label: {
                            Image(systemName: "pencil")
                                .font(.title)
                                .foregroundColor(.white)
                                .padding(.trailing, 0)
                        })
                        .alert("New deck name", isPresented: $showingDeckNameChange) {
                            TextField("", text: $newDeckName)
                            Button("OK") {
                                newDeckName = String(newDeckName.prefix(25))
                                contentManagerVM.decks[contentManagerVM.selectedDeckId].name = newDeckName
                                SaveManager.saveDecks(contentManagerVM.decks)
                            }
                            Button("Cancel", role: .cancel) {
                                newDeckName = contentManagerVM.selectedDeck.name
                            }
                        } message: {
                            Text("25 characters max")
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
                }.pickerStyle(.menu).font(.subheadline).frame(height: 24).buttonLabel().opacity(planechaseVM.isPremium ? 1 : 0.6).frame(minWidth: 180)
                .onChange(of: deckSelected) { newValue in
                    withAnimation(.easeInOut(duration: 0.3)) {
                        contentManagerVM.changeSelectedDeck(newDeckId: newValue)
                        newDeckName = contentManagerVM.selectedDeck.name
                    }
                }
                .onAppear() {
                    deckSelected = contentManagerVM.selectedDeckId
                    newDeckName = contentManagerVM.selectedDeck.name
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
        @EnvironmentObject var contentManagerVM: ContentManagerViewModel
        @ObservedObject var card: Card
        @State private var showingDeleteAlert = false
        let width: CGFloat
        let height: CGFloat
        
        var body: some View {
            ZStack {
                if card.image == nil {
                    Color.black
                        .frame(width: width,
                               height: height)
                        .cornerRadius(CardSizes.cornerRadiusForWidth(width))
                        .onAppear {
                            card.cardAppears()
                        }
                } else {
                    Image(uiImage: card.image!)
                        .resizable()
                        .frame(width: width,
                               height: height)
                        .cornerRadius(CardSizes.cornerRadiusForWidth(width))
                }
            }
            .padding(5)
            .overlay(
                RoundedRectangle(cornerRadius: CardSizes.cornerRadiusForWidth(width) + CardSizes.selectionBorderAdditionalCornerRadius)
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
