//
//  FilterSheet.swift
//  Planechase
//
//  Created by Loic D on 17/09/2023.
//

import SwiftUI

extension ContentManagerView {
    struct FilterSheet: View {
        @Environment(\.presentationMode) var presentationMode
        @EnvironmentObject var planechaseVM: PlanechaseViewModel
        @EnvironmentObject var contentVM: ContentManagerViewModel
        
        let columns = [
            GridItem(.adaptive(minimum: 150, maximum: 150))
        ]
        
        var body: some View {
            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }, label: {
                            Image(systemName: "xmark")
                                .imageButtonLabel()
                        })
                        Text("collection_filter_onlyShow".translate()).title()
                        Spacer()
                        Text("\(contentVM.filteredCardCollection.count)/\(contentVM.cardCollection.count)").title()
                    }
                    
                    //Rectangle().frame(height: 2).foregroundColor(.white).padding(.horizontal, 10)
                    
                    ZStack(alignment: .topLeading) {
                        Text("Cards type:").headline().padding(.top, 15)
                        HStack {
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    contentVM.collectionFilter.cardType.toggle(value: .official)
                                    contentVM.updateFilteredCardCollection()
                                }
                            }, label: {
                                Text("collection_filter_official".translate())
                                    .textButtonLabel(style: contentVM.collectionFilter.cardType == .official ? .secondary : .primary)
                            })
                            
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    contentVM.collectionFilter.cardType.toggle(value: .unofficial)
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        contentVM.collectionFilter.cardSet = nil
                                    }
                                    contentVM.updateFilteredCardCollection()
                                }
                            }, label: {
                                Text("collection_filter_unofficial".translate())
                                    .textButtonLabel(style: contentVM.collectionFilter.cardType == .unofficial ? .secondary : .primary)
                            })
                        }.padding(.leading, 120)
                    }
                    
                    //Rectangle().frame(height: 2).foregroundColor(.white).padding(.horizontal, 10)
                    
                    ZStack(alignment: .topLeading) {
                        Text("Cards selection:").headline().padding(.top, 15)
                        HStack {
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    contentVM.collectionFilter.cardsInDeck.toggle(value: .present)
                                    contentVM.updateFilteredCardCollection()
                                }
                            }, label: {
                                Text("collection_filter_present".translate())
                                    .textButtonLabel(style: contentVM.collectionFilter.cardsInDeck == .present ? .secondary : .primary)
                            })
                            
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    contentVM.collectionFilter.cardsInDeck.toggle(value: .absent)
                                    contentVM.updateFilteredCardCollection()
                                }
                            }, label: {
                                Text("collection_filter_absent".translate())
                                    .textButtonLabel(style: contentVM.collectionFilter.cardsInDeck == .absent ? .secondary : .primary)
                            })
                            
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    contentVM.collectionFilter.cardsInDeck.toggle(value: .absentInAll)
                                    contentVM.updateFilteredCardCollection()
                                }
                            }, label: {
                                Text("collection_filter_absentAll".translate())
                                    .textButtonLabel(style: contentVM.collectionFilter.cardsInDeck == .absentInAll ? .secondary : .primary)
                            })
                        }.padding(.leading, 120)
                    }
                    
                    //Rectangle().frame(height: 2).foregroundColor(.white).padding(.horizontal, 10)
                    
                    ZStack(alignment: .topLeading) {
                        Text("Sort by set").headline().padding(.top, 15)
                        HStack(alignment: .top) {
                            LazyVGrid(columns: columns) {
                                ForEach(CardSet.getAll(), id: \.self) { cardSet in
                                    CardSetButtonView(cardSet: cardSet)
                                }
                            }.frame(maxWidth: .infinity)
                        }.padding(.leading, 120)
                    }
                    
                    Spacer()
                    
                    Group {
                        Button(action: {
                            contentVM.removeAllOfficialCards()
                        }, label: {
                            Text("Reset")
                                .textButtonLabel()
                        })
                    }
                }.padding(.horizontal, 30).padding(.top, 30)
            }
            .background(GradientView(gradientId: planechaseVM.gradientId))
        }
        
        struct CardSetButtonView: View {
            @EnvironmentObject var contentVM: ContentManagerViewModel
            let cardSet: CardSet
            var isSelected: Bool {
                return contentVM.collectionFilter.cardSet == cardSet
            }
            var body: some View {
                Button(action: {
                    if isSelected {
                        contentVM.collectionFilter.cardSet = nil
                    } else {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            contentVM.collectionFilter.cardType = .official
                        }
                        contentVM.collectionFilter.cardSet = cardSet
                    }
                    contentVM.updateFilteredCardCollection()
                }, label: {
                    Text(cardSet.setName())
                        .textButtonLabel(style: isSelected ? .secondary : .primary)
                        .frame(width: 150)
                })
            }
        }
    }
}

