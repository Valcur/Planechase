//
//  ContentManagerView+Filter.swift
//  Planechase
//
//  Created by Loic D on 24/03/2023.
//

import SwiftUI

extension ContentManagerView {
    struct FilterRow: View {
        @EnvironmentObject var contentVM: ContentManagerViewModel
        
        var body: some View {
            HStack(spacing: 0) {
                Text("collection_filter_onlyShow".translate()).headline()
                
                Spacer()
                
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
                
                Spacer()
                Rectangle().frame(width: 2, height: 40).foregroundColor(.white)
                Spacer()
                
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
            }
        }
    }
    
    struct BottomRow: View {
        @EnvironmentObject var contentManagerVM: ContentManagerViewModel
        @Binding var smallGridModEnable: Bool
        
        var body: some View {
            HStack {
                Text("collection_howToUse".translate())
                    .headline()
                    .padding(5)
                
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
            }
        }
    }
}
