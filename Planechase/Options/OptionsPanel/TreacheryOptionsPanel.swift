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
            Array(repeating: GridItem(.flexible()), count: 3)
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
                                    .frame(width: (geo.size.width / 3) - 20)
                                    .cornerRadius(CardSizes.classic_cornerRadiusForWidth((geo.size.width / 3) - 20))
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
    }
}
