//
//  FilterSheet.swift
//  Planechase
//
//  Created by Loic D on 17/09/2023.
//

import SwiftUI

extension ContentManagerView {
    struct FilterSheet: View {
        @EnvironmentObject var planechaseVM: PlanechaseViewModel
        @EnvironmentObject var contentVM: ContentManagerViewModel
        
        var body: some View {
            VStack(alignment: .leading, spacing: 20) {
                Text("collection_filter_onlyShow".translate()).title()
                
                Rectangle().frame(height: 2).foregroundColor(.white).padding(.horizontal, 30)
                
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
                            contentVM.updateFilteredCardCollection()
                        }
                    }, label: {
                        Text("collection_filter_unofficial".translate())
                            .textButtonLabel(style: contentVM.collectionFilter.cardType == .unofficial ? .secondary : .primary)
                    })
                }
                
                Rectangle().frame(height: 2).foregroundColor(.white).padding(.horizontal, 30)
                
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
                }
                
                Rectangle().frame(height: 2).foregroundColor(.white).padding(.horizontal, 30)
                
                ScrollView(.horizontal) {
                    HStack(spacing: 10) {
                        Text("Sort by set")
                            .headline()
                        
                        ForEach(CardSet.getAll(), id: \.self) { cardSet in
                            CardSetButtonView(cardSet: cardSet)
                        }
                    }.padding(.vertical, 10)
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
            }
            .background(GradientView(gradientId: planechaseVM.gradientId))
        }
        
        struct CardSetButtonView: View {
            @EnvironmentObject var contentVM: ContentManagerViewModel
            let cardSet: CardSet
            var isSelected: Bool {
                return contentVM.collectionFilter.cardSets.contains(cardSet)
            }
            var body: some View {
                Button(action: {
                    if isSelected {
                        contentVM.collectionFilter.cardSets.removeAll(where: { $0 == cardSet })
                    } else {
                        contentVM.collectionFilter.cardSets.append(cardSet)
                    }
                    contentVM.updateFilteredCardCollection()
                }, label: {
                    Text(cardSet.setName())
                        .textButtonLabel(style: isSelected ? .primary : .secondary)
                })
            }
        }
    }
}

