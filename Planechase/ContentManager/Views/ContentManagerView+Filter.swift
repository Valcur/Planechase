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
            HStack(spacing: 30) {
                HStack {
                    Text("Only show").headline()
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            contentVM.collectionFilter.cardType.toggle(value: .official)
                            contentVM.updateFilteredCardCollection()
                        }
                    }, label: {
                        Text("Official cards")
                            .textButtonLabel(style: contentVM.collectionFilter.cardType == .official ? .secondary : .primary)
                    })
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            contentVM.collectionFilter.cardType.toggle(value: .unofficial)
                            contentVM.updateFilteredCardCollection()
                        }
                    }, label: {
                        Text("Unofficial cards")
                            .textButtonLabel(style: contentVM.collectionFilter.cardType == .unofficial ? .secondary : .primary)
                    })
                }
                
                HStack {
                    Text("Only show").headline()
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            contentVM.collectionFilter.cardsInDeck.toggle(value: .present)
                            contentVM.updateFilteredCardCollection()
                        }
                    }, label: {
                        Text("Cards in")
                            .textButtonLabel(style: contentVM.collectionFilter.cardsInDeck == .present ? .secondary : .primary)
                    })
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            contentVM.collectionFilter.cardsInDeck.toggle(value: .absent)
                            contentVM.updateFilteredCardCollection()
                        }
                    }, label: {
                        Text("Cards not in")
                            .textButtonLabel(style: contentVM.collectionFilter.cardsInDeck == .absent ? .secondary : .primary)
                    })
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            contentVM.collectionFilter.cardsInDeck.toggle(value: .absentInAll)
                            contentVM.updateFilteredCardCollection()
                        }
                    }, label: {
                        Text("Absent from all")
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
