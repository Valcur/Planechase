//
//  OptionsMenuView.swift
//  Planechase
//
//  Created by Loic D on 23/02/2023.
//

import SwiftUI

struct OptionsMenuView: View {
    @EnvironmentObject var planechaseVM: PlanechaseViewModel
    @State var selectedMenu: MenuSelection = .options
    
    var body: some View {
        ZStack {
            GradientView(gradientId: planechaseVM.gradientId)
            
            HStack {
                VStack(spacing: 20) {
                    MenuSelectionView(menu: .options, selectedMenu: $selectedMenu)
                    
                    MenuSelectionView(menu: .contact, selectedMenu: $selectedMenu)
                }.frame(width: 200)
                
                if selectedMenu == .options {
                    OptionsPanel()
                } else if selectedMenu == .contact {
                    ContactPanel()
                }
            }
        }
    }
    
    struct MenuSelectionView: View {
        let menu: MenuSelection
        @Binding var selectedMenu: MenuSelection
        
        var body: some View {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    selectedMenu = menu
                }
            }, label: {
                Text(menu.title())
                    .title()
            }).opacity(menu == selectedMenu ? 1 : 0.6)
        }
    }
    
    struct OptionsPanel: View {
        var body: some View {
            VStack {
                Text("Background Color")
                    .title()
                
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
                }
            }.scrollablePanel()
        }
        
        struct MenuCustomBackgroundColorChoiceView: View {
            @EnvironmentObject var planechaseVM: PlanechaseViewModel
            let gradientId: Int
            
            var body: some View {
                Button(action: {
                    print("Changing background color to \(gradientId)")
                    planechaseVM.setGradientId(gradientId)
                }, label: {
                    GradientView(gradientId: gradientId).cornerRadius(15).frame(width: 150, height: 150).overlay(
                        RoundedRectangle(cornerRadius: 19).stroke(planechaseVM.gradientId == gradientId ? .white : .clear, lineWidth: 4)).padding(10)
                })
            }
        }
    }
    
    struct ContactPanel: View {
        var body: some View {
            VStack {
                Text("Thanks")
                    .title()
            }.scrollablePanel()
        }
    }
    
    enum MenuSelection {
        case options
        case contact
        
        func title() -> String {
            switch self {
            case .options:
                return "Options"
            case .contact:
                return "Contact"
            }
        }
    }
}

struct OptionsMenuView_Previews: PreviewProvider {
    static var previews: some View {
        OptionsMenuView()
    }
}
