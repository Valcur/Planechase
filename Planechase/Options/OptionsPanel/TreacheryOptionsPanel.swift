//
//  TreacheryOptionsPanel.swift
//  Planechase
//
//  Created by Loic D on 12/03/2023.
//

import SwiftUI

extension OptionsMenuView {
    struct TreacheryOptionsPanel: View {
        @EnvironmentObject var planechaseVM: PlanechaseViewModel
        private var gridItemLayout: [GridItem]  {
            Array(repeating: GridItem(.flexible()), count: UIDevice.isIPhone ? 2 : 3)
        }
        @State var allRole = [TreacheryData.TreacheryRoleData]()
        
        var body: some View {
            GeometryReader { geo in
                VStack(alignment: .leading, spacing: 15) {
                    Text("Treachery".translate())
                        .title()
                    
                    Link(destination: URL(string: "https://mtgtreachery.net/en/")!, label: {
                        Text("options_treachery_link".translate())
                            .underlinedLink()
                    })
                    
                    Toggle("options_treachery_enable".translate(), isOn: $planechaseVM.treacheryOptions.isTreacheryEnabled)
                        .font(.subheadline).foregroundColor(.white)
                    
                    RolesRepartition()
                    
                    Text("options_treachery_recommanded".translate())
                        .headline()
                    
                    Toggle("options_treachery_unco".translate(), isOn: $planechaseVM.treacheryOptions.isUsingUnco)
                        .font(.subheadline).foregroundColor(.white)
                    
                    Toggle("options_treachery_rare".translate(), isOn: $planechaseVM.treacheryOptions.isUsingRare)
                        .font(.subheadline).foregroundColor(.white)
                    
                    Toggle("options_treachery_mythic".translate(), isOn: $planechaseVM.treacheryOptions.isUsingMythic)
                        .font(.subheadline).foregroundColor(.white)
                    
                    LazyVGrid(columns: gridItemLayout, spacing: 20) {
                        ForEach(0..<allRole.count, id: \.self) { i in
                            if i < allRole.count, let card = allRole[i] {
                                Image(card.name)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: (geo.size.width / (UIDevice.isIPhone ? 2 : 3)) - 20)
                                    .cornerRadius(CardSizes.classic_cornerRadiusForWidth((geo.size.width / (UIDevice.isIPhone ? 2 : 3)) - 20))
                                    .id(card.name)
                            }
                        }
                    }
                    
                }.scrollablePanel()
            }
            .onChange(of: planechaseVM.treacheryOptions.isTreacheryEnabled) { _ in
                planechaseVM.saveTreacheryOptions()
            }
            .onChange(of: planechaseVM.treacheryOptions.isUsingUnco) { _ in
                planechaseVM.treacheryData.filter(planechaseVM.getSelectedRarities())
                updateAllRole()
                planechaseVM.saveTreacheryOptions()
            }
            .onChange(of: planechaseVM.treacheryOptions.isUsingRare) { _ in
                planechaseVM.treacheryData.filter(planechaseVM.getSelectedRarities())
                updateAllRole()
                planechaseVM.saveTreacheryOptions()
            }
            .onChange(of: planechaseVM.treacheryOptions.isUsingMythic) { _ in
                planechaseVM.treacheryData.filter(planechaseVM.getSelectedRarities())
                updateAllRole()
                planechaseVM.saveTreacheryOptions()
            }
            .onAppear() {
                updateAllRole()
            }
        }
        
        func updateAllRole() {
            withAnimation(.easeInOut(duration: 0.3)) {
                allRole = planechaseVM.treacheryData.getAllRole()
            }
        }
        
        struct RolesRepartition: View {
            @EnvironmentObject var planechaseVM: PlanechaseViewModel
            @State var rolesRepartition: [TreacheryRole] = []
            var body: some View {
                VStack(spacing: 15) {
                    HStack {
                        Text("options_treachery_roleRepartition".translate())
                            .headline()
                        Spacer()
                        Button(action: {
                            rolesRepartition = TreacheryRole.getDefault()
                        }, label: {
                            Text("reset".translate())
                                .textButtonLabel()
                        })
                    }
                    VStack {
                        HStack {
                            Text("options_treachery_players".translate())
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(width: 70)
                            
                            ForEach(0..<rolesRepartition.count, id: \.self) { i in
                                Text("\(i + 1)\n\("options_treachery_players".translate())")
                                    .font(UIDevice.isIPhone ? .footnote : .headline)
                                    .fontWeight(.bold)
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .opacity(i == 0 ? 0 : 1)
                            }
                        }
                        HStack {
                            Text("options_treachery_role".translate())
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(width: 70)
                            
                            ForEach(0..<rolesRepartition.count, id: \.self) { i in
                                Button(action: {
                                    let role = rolesRepartition[i]
                                    withAnimation(.easeInOut(duration: 0.000001)) {
                                        if role == .leader {
                                            rolesRepartition[i] = .guardian
                                        } else if role == .guardian {
                                            rolesRepartition[i] = .assassin
                                        } else if role == .assassin {
                                            rolesRepartition[i] = .traitor
                                        } else if role == .traitor {
                                            rolesRepartition[i] = .leader
                                        }
                                    }
                                }, label: {
                                    ZStack {
                                        Rectangle()
                                            .frame(height: 50)
                                            .foregroundColor(Color(rolesRepartition[i].color()))
                                            .cornerRadius(15)
                                        
                                        if UIDevice.isIPad {
                                            Text(rolesRepartition[i].name())
                                                .font(.headline)
                                                .fontWeight(.bold)
                                                .foregroundColor(.white)
                                        } else {
                                            Text(rolesRepartition[i].name().prefix(1))
                                                .font(.headline)
                                                .fontWeight(.bold)
                                                .foregroundColor(.white)
                                        }
                                    }
                                }).frame(maxWidth: .infinity)
                            }
                        }
                    }.padding(.horizontal, 8).padding(.vertical, 15)
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(.white, lineWidth: 2))
                }.padding(.bottom, 5)
                .onAppear() {
                    rolesRepartition = SaveManager.getTreacheryRolesRepartition()
                }.onChange(of: rolesRepartition) { _ in
                    SaveManager.saveTreacheryRolesRepartition(rolesRepartition)
                }
            }
        }
    }
}
