//
//  ContentManagerView+Filter.swift
//  Planechase
//
//  Created by Loic D on 24/03/2023.
//

import SwiftUI

extension ContentManagerView {    
    struct BottomRow: View {
        @EnvironmentObject var contentManagerVM: ContentManagerViewModel
        @Binding var smallGridModEnable: Bool
        @Binding var isFullscreen: Bool
        
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
                    
                    Text("/").font(.title).fontWeight(.light).foregroundColor(.white)
                    
                    Button(action: {
                        isFullscreen = true
                    }, label: {
                        Image(systemName: "arrow.up.left.and.arrow.down.right")
                            .font(.title)
                            .foregroundColor(.white)
                    }).opacity(0.6)
                }
            }
        }
    }
}

