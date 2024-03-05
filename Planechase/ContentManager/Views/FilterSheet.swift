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
        private var columns: [GridItem]  {
            [GridItem(.adaptive(minimum: 230, maximum: 370))]
        }
        private let leadingOffset: CGFloat = 100
        
        var body: some View {
            GeometryReader { geo in
                ScrollView(.vertical) {
                    VStack(alignment: .leading, spacing: 30) {
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
                        }//.background(Color.black.opacity(0.6))
                        
                        ZStack(alignment: .topLeading) {
                            Text("collection_filter_title_source".translate()).headline().padding(.top, 20)
                            HStack {
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        contentVM.collectionFilter.cardType.toggle(value: .official)
                                        contentVM.updateFilteredCardCollection()
                                    }
                                }, label: {
                                    Text("collection_filter_official".translate())
                                        .textButtonLabel(style: contentVM.collectionFilter.cardType == .official ? .secondary : .noBackground)
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
                                        .textButtonLabel(style: contentVM.collectionFilter.cardType == .unofficial ? .secondary : .noBackground)
                                })
                            }.padding(.leading, leadingOffset)
                        }.frame(maxWidth: .infinity, alignment: .topLeading).padding(10).blurredBackground()
                        
                        ZStack(alignment: .topLeading) {
                            Text("collection_filter_title_selection".translate()).headline().padding(.top, 20)
                            HStack {
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        contentVM.collectionFilter.cardsInDeck.toggle(value: .present)
                                        contentVM.updateFilteredCardCollection()
                                    }
                                }, label: {
                                    Text("collection_filter_present".translate())
                                        .textButtonLabel(style: contentVM.collectionFilter.cardsInDeck == .present ? .secondary : .noBackground)
                                })
                                
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        contentVM.collectionFilter.cardsInDeck.toggle(value: .absent)
                                        contentVM.updateFilteredCardCollection()
                                    }
                                }, label: {
                                    Text("collection_filter_absent".translate())
                                        .textButtonLabel(style: contentVM.collectionFilter.cardsInDeck == .absent ? .secondary : .noBackground)
                                })
                                
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        contentVM.collectionFilter.cardsInDeck.toggle(value: .absentInAll)
                                        contentVM.updateFilteredCardCollection()
                                    }
                                }, label: {
                                    Text("collection_filter_absentAll".translate())
                                        .textButtonLabel(style: contentVM.collectionFilter.cardsInDeck == .absentInAll ? .secondary : .noBackground)
                                })
                            }.padding(.leading, leadingOffset)
                        }.frame(maxWidth: .infinity, alignment: .topLeading).padding(10).blurredBackground()
                        
                        ZStack(alignment: .topLeading) {
                            Text("collection_filter_title_type".translate()).headline().padding(.top, 20)
                            HStack {
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        contentVM.toggleCardTypeLineFilter(.plane)
                                    }
                                }, label: {
                                    Text("plane".translate())
                                        .textButtonLabel(style: contentVM.collectionFilter.cardTypeLine == .plane ? .secondary : .noBackground)
                                })
                                
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        contentVM.toggleCardTypeLineFilter(.phenomenon)
                                    }
                                }, label: {
                                    Text("phenomenon".translate())
                                        .textButtonLabel(style: contentVM.collectionFilter.cardTypeLine == .phenomenon ? .secondary : .noBackground)
                                })
                            }.padding(.leading, leadingOffset)
                        }.frame(maxWidth: .infinity, alignment: .topLeading).padding(10).blurredBackground()
                        
                        ZStack(alignment: .topLeading) {
                            Text("collection_filter_title_set".translate()).headline().padding(.top, 20)
                            HStack(alignment: .top) {
                                LazyVGrid(columns: columns, spacing: 5) {
                                    ForEach(CardSet.getAll(), id: \.self) { cardSet in
                                        CardSetButtonView(cardSet: cardSet)
                                    }
                                }.frame(maxWidth: .infinity)
                            }.padding(.leading, leadingOffset)
                        }.frame(maxWidth: .infinity, alignment: .topLeading).padding(10).blurredBackground()
                        
                        ZStack(alignment: .topLeading) {
                            Text("collection_filter_title_lang".translate()).headline().padding(.top, 20)
                            HStack(alignment: .top) {
                                ForEach(["en", "non-en"], id: \.self) { cardLang in
                                    Button(action: {
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            contentVM.toggleCardLangFilter(cardLang)
                                        }
                                    }, label: {
                                        Text("collection_filter_lang_\(cardLang)".translate())
                                            .textButtonLabel(style: contentVM.collectionFilter.cardLang == cardLang ? .secondary : .noBackground)
                                    })
                                }
                            }.padding(.leading, leadingOffset)
                        }.frame(maxWidth: .infinity, alignment: .topLeading).padding(10).blurredBackground()
                    }.padding(.horizontal, 30).padding(.top, 30).iPhoneScaler_widthOnly(width: geo.size.width, anchor: .top)
                }
            }.background(GradientView(gradientId: planechaseVM.gradientId))
        }
        
        struct CardSetButtonView: View {
            @EnvironmentObject var contentVM: ContentManagerViewModel
            let cardSet: CardSet
            var isSelected: Bool {
                return contentVM.collectionFilter.cardSet == cardSet
            }
            var body: some View {
                HStack {
                    Button(action: {
                        if isSelected {
                            contentVM.collectionFilter.cardSet = nil
                        } else {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                contentVM.collectionFilter.cardType = .both
                            }
                            contentVM.collectionFilter.cardSet = cardSet
                        }
                        contentVM.updateFilteredCardCollection()
                    }, label: {
                        Text(cardSet.setName())
                            .textButtonLabel(style: isSelected ? .secondary : .noBackground)
                            .frame(maxHeight: 70)
                    })
                    Spacer()
                }
            }
        }
    }
}

