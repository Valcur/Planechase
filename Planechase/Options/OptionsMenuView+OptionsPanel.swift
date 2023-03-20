//
//  OptionsMenuView+OptionsPanel.swift
//  Planechase
//
//  Created by Loic D on 12/03/2023.
//

import SwiftUI

extension OptionsMenuView {
    struct OptionsPanel: View {
        @EnvironmentObject var planechaseVM: PlanechaseViewModel
        
        var body: some View {
            VStack(alignment: .leading, spacing: 15) {
                Group {
                    HStack {
                        if !planechaseVM.isPremium {
                            Image(systemName: "crown.fill")
                                .font(.title)
                                .foregroundColor(.white)
                        }
                        
                        Text("options_backgroundColor".translate())
                            .title()
                        
                        Spacer()
                    }
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            MenuCustomBackgroundColorChoiceView(gradientId: 1)
                            MenuCustomBackgroundColorChoiceView(gradientId: 2)
                            MenuCustomBackgroundColorChoiceView(gradientId: 3)
                            MenuCustomBackgroundColorChoiceView(gradientId: 4)
                            MenuCustomBackgroundColorChoiceView(gradientId: 5)
                            MenuCustomBackgroundColorChoiceView(gradientId: 6)
                            MenuCustomBackgroundColorChoiceView(gradientId: 7)
                            MenuCustomBackgroundColorChoiceView(gradientId: 8)
                        }
                    }.disabled(!planechaseVM.isPremium).opacity(planechaseVM.isPremium ? 1 : 0.6)
                }
                
                Group {
                    Text("options_ui_title".translate())
                        .title()
                    
                    HStack {
                        Text("options_ui_zoomType".translate())
                            .headline()
                        
                        Spacer()
                        
                        ZoomViewTypeView(zoomType: .one)
                        
                        Text("/").font(.title).fontWeight(.light).foregroundColor(.white)
                        
                        ZoomViewTypeView(zoomType: .two)
                        
                        Text("/").font(.title).fontWeight(.light).foregroundColor(.white)
                        
                        ZoomViewTypeView(zoomType: .four)
                    }
                    
                    Toggle("options_ui_biggerCardsOnMap".translate(), isOn: $planechaseVM.biggerCardsOnMap)
                        .font(.subheadline).foregroundColor(.white)
                    
                    Toggle("options_ui_hellridePng".translate(), isOn: $planechaseVM.useHellridePNG)
                        .font(.subheadline).foregroundColor(.white)
                }
                
                Group {
                    Text("options_dice_title".translate())
                        .title()
                    
                    HStack {
                        if !planechaseVM.isPremium {
                            Image(systemName: "crown.fill")
                                .font(.subheadline)
                                .foregroundColor(.white)
                        }
                        
                        Text("options_dice_style".translate())
                            .headline()
                        
                        Spacer()
                    }
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            MenuCustomDiceChoiceView(diceStyleId: 0)
                            MenuCustomDiceChoiceView(diceStyleId: 1)
                            MenuCustomDiceChoiceView(diceStyleId: 2)
                            MenuCustomDiceChoiceView(diceStyleId: 3)
                            MenuCustomDiceChoiceView(diceStyleId: 4)
                            MenuCustomDiceChoiceView(diceStyleId: 5)
                        }.padding(10)
                    }.disabled(!planechaseVM.isPremium).opacity(planechaseVM.isPremium ? 1 : 0.6)
                    
                    HStack {
                        if !planechaseVM.isPremium {
                            Image(systemName: "crown.fill")
                                .font(.subheadline)
                                .foregroundColor(.white)
                        }
                        
                        Text("options_dice_color".translate())
                            .headline()
                        
                        Spacer()
                    }
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            MenuCustomDiceColorChoiceView(diceColorId: 0)
                            MenuCustomDiceColorChoiceView(diceColorId: 1)
                            MenuCustomDiceColorChoiceView(diceColorId: 2)
                            MenuCustomDiceColorChoiceView(diceColorId: 3)
                            MenuCustomDiceColorChoiceView(diceColorId: 4)
                            MenuCustomDiceColorChoiceView(diceColorId: 5)
                            MenuCustomDiceColorChoiceView(diceColorId: 6)
                            MenuCustomDiceColorChoiceView(diceColorId: 7)
                        }.padding(10)
                    }.disabled(!planechaseVM.isPremium).opacity(planechaseVM.isPremium ? 1 : 0.6)
                    
                    Toggle("options_dice_choiceFace".translate(), isOn: $planechaseVM.diceOptions.useChoiceDiceFace)
                        .font(.subheadline).foregroundColor(.white)
                    
                    HStack(spacing: 15) {
                        Text("options_dice_numberOfFace".translate())
                            .headline()
                        
                        Spacer()
                        
                        MenuNumberOfFaceChoiceView(numberOfFace: 4)
                        MenuNumberOfFaceChoiceView(numberOfFace: 5)
                        MenuNumberOfFaceChoiceView(numberOfFace: 6)
                        MenuNumberOfFaceChoiceView(numberOfFace: 7)
                        MenuNumberOfFaceChoiceView(numberOfFace: 8)
                    }
                }
            }.scrollablePanel()
                .onChange(of: planechaseVM.biggerCardsOnMap) { _ in
                    planechaseVM.saveToggles()
                }
                .onChange(of: planechaseVM.useHellridePNG) { _ in
                    planechaseVM.saveToggles()
                }
        }
        
        struct ZoomViewTypeView: View {
            @EnvironmentObject var planechaseVM: PlanechaseViewModel
            let zoomType: ZoomViewType
            var imageName: String {
                if zoomType == .one {
                    return "square"
                } else if zoomType == .two {
                    return "rectangle.grid.1x2"
                } else {
                    return "square.grid.2x2"
                }
            }
            
            var body: some View {
                Button(action: {
                    planechaseVM.setZoomViewType(zoomType)
                }, label: {
                    Image(systemName: imageName)
                        .font(.title)
                        .foregroundColor(.white)
                }).opacity(planechaseVM.zoomViewType == zoomType ? 1 : 0.6)
            }
        }
        
        struct MenuCustomBackgroundColorChoiceView: View {
            @EnvironmentObject var planechaseVM: PlanechaseViewModel
            let gradientId: Int
            
            var body: some View {
                Button(action: {
                    print("Changing background color to \(gradientId)")
                    planechaseVM.setGradientId(gradientId)
                }, label: {
                    GradientView(gradientId: gradientId).cornerRadius(15).frame(width: 120, height: 120).overlay(
                        RoundedRectangle(cornerRadius: 19).stroke(planechaseVM.gradientId == gradientId ? .white : .clear, lineWidth: 4)).padding(10)
                })
            }
        }
        
        struct MenuCustomDiceChoiceView: View {
            @EnvironmentObject var planechaseVM: PlanechaseViewModel
            let diceStyleId: Int
            
            var body: some View {
                Button(action: {
                    print("Changing dice style to \(diceStyleId)")
                    planechaseVM.setDiceOptions(DiceOptions(diceStyle: diceStyleId,
                                                            diceColor: planechaseVM.diceOptions.diceColor,
                                                            numberOfFace: planechaseVM.diceOptions.numberOfFace,
                                                            useChoiceDiceFace: planechaseVM.diceOptions.useChoiceDiceFace))
                }, label: {
                    ZStack {
                        DiceOptions.getBackground(planechaseVM.diceOptions.diceColor)
                        
                        Image("Choice")
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(DiceOptions.getForegroundColor(planechaseVM.diceOptions.diceColor))
                            .padding(10)
                        
                        DiceOverlay(diceStyleId: diceStyleId, diceColorId: planechaseVM.diceOptions.diceColor)
                    }.frame(width: 73, height: 73)
                        .cornerRadius(8)
                        .padding(8)
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(planechaseVM.diceOptions.diceStyle == diceStyleId ? .white : .clear, lineWidth: 4))
                })
            }
        }
        
        struct MenuCustomDiceColorChoiceView: View {
            @EnvironmentObject var planechaseVM: PlanechaseViewModel
            let diceColorId: Int
            
            var body: some View {
                Button(action: {
                    print("Changing dice color to \(diceColorId)")
                    planechaseVM.setDiceOptions(DiceOptions(diceStyle: planechaseVM.diceOptions.diceStyle,
                                                            diceColor: diceColorId,
                                                            numberOfFace: planechaseVM.diceOptions.numberOfFace,
                                                            useChoiceDiceFace: planechaseVM.diceOptions.useChoiceDiceFace))
                }, label: {
                    ZStack {
                        DiceOptions.getBackground(diceColorId)
                        
                        Image("Choice")
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(DiceOptions.getForegroundColor(diceColorId))
                            .padding(10)
                        
                        DiceOverlay(diceStyleId: planechaseVM.diceOptions.diceStyle, diceColorId: diceColorId)
                    }.frame(width: 73, height: 73)
                        .cornerRadius(8)
                        .padding(8)
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(planechaseVM.diceOptions.diceColor == diceColorId ? .white : .clear, lineWidth: 4))
                })
            }
        }
        
        struct MenuNumberOfFaceChoiceView: View {
            @EnvironmentObject var planechaseVM: PlanechaseViewModel
            let numberOfFace: Int
            var isSelected: Bool {
                planechaseVM.diceOptions.numberOfFace == numberOfFace
            }
            
            var body: some View {
                Button(action: {
                    planechaseVM.setDiceOptions(DiceOptions(diceStyle: planechaseVM.diceOptions.diceStyle,
                                                            diceColor: planechaseVM.diceOptions.diceColor,
                                                            numberOfFace: numberOfFace,
                                                            useChoiceDiceFace: planechaseVM.diceOptions.useChoiceDiceFace))
                }, label: {
                    Text("\(numberOfFace)")
                        .font(.title2)
                        .fontWeight(isSelected ? .bold : .regular)
                        .foregroundColor(.white)
                        .opacity(isSelected ? 1 : 0.7)
                })
            }
        }
    }
}
