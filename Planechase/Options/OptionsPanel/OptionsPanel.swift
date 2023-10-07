//
//  OptionsPanel.swift
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
                    }.premiumRestricted(planechaseVM.isPremium)
                    
                    Toggle("options_blurredBackground".translate(), isOn: $planechaseVM.useBlurredBackground)
                        .font(.subheadline).foregroundColor(.white)
                        .premiumRestricted(planechaseVM.isPremium)
                        .premiumCrowned(planechaseVM.isPremium)
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
                        
                        ZoomViewTypeView(zoomType: .two_cropped)
                        
                        Text("/").font(.title).fontWeight(.light).foregroundColor(.white)
                        
                        ZoomViewTypeView(zoomType: .four)
                    }
                    
                    Toggle("options_ui_biggerCardsOnMap".translate(), isOn: $planechaseVM.biggerCardsOnMap)
                        .font(.subheadline).foregroundColor(.white)
                    
                    Toggle("options_ui_hellridePng".translate(), isOn: $planechaseVM.useHellridePNG)
                        .font(.subheadline).foregroundColor(.white)
                    
                    Toggle("options_ui_noDice".translate(), isOn: $planechaseVM.noDice)
                        .font(.subheadline).foregroundColor(.white)
                    
                    Toggle("options_ui_noHammer".translate(), isOn: $planechaseVM.noHammerRow)
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
                            Group {
                                MenuCustomDiceChoiceView(diceStyleId: 0)
                                MenuCustomDiceChoiceView(diceStyleId: 1)
                                MenuCustomDiceChoiceView(diceStyleId: 2)
                                MenuCustomDiceChoiceView(diceStyleId: 3)
                                MenuCustomDiceChoiceView(diceStyleId: 4)
                                MenuCustomDiceChoiceView(diceStyleId: 5)
                            }
                            //MenuCustomDiceChoiceView(diceStyleId: 6)
                            //MenuCustomDiceChoiceView(diceStyleId: 7)
                            //MenuCustomDiceChoiceView(diceStyleId: 8)
                            MenuCustomDiceChoiceView(diceStyleId: 9)
                            MenuCustomDiceChoiceView(diceStyleId: 10)
                            MenuCustomDiceChoiceView(diceStyleId: 11)
                            MenuCustomDiceChoiceView(diceStyleId: 12)
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
                            Group {
                                MenuCustomDiceColorChoiceView(diceColorId: 0)
                                MenuCustomDiceColorChoiceView(diceColorId: 1)
                                MenuCustomDiceColorChoiceView(diceColorId: 2)
                                MenuCustomDiceColorChoiceView(diceColorId: 3)
                                MenuCustomDiceColorChoiceView(diceColorId: 4)
                                MenuCustomDiceColorChoiceView(diceColorId: 5)
                                MenuCustomDiceColorChoiceView(diceColorId: 6)
                                MenuCustomDiceColorChoiceView(diceColorId: 7)
                            }
                            MenuCustomDiceColorChoiceView(diceColorId: 8)
                            MenuCustomDiceColorChoiceView(diceColorId: 9)
                            MenuCustomDiceColorChoiceView(diceColorId: 10)
                            MenuCustomDiceColorChoiceView(diceColorId: 11)
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
                .onChange(of: planechaseVM.noHammerRow) { _ in
                    planechaseVM.saveToggles()
                }
                .onChange(of: planechaseVM.noDice) { _ in
                    planechaseVM.saveToggles()
                }
                .onChange(of: planechaseVM.useBlurredBackground) { _ in
                    planechaseVM.saveToggles()
                }
        }
    }
}
