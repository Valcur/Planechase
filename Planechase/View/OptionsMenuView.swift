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
        @EnvironmentObject var planechaseVM: PlanechaseViewModel
        
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
                
                HStack {
                    Text("Zoom type")
                        .headline()
                    
                    Spacer()
                    
                    ZoomViewTypeView(zoomType: .one)
                    
                    Text("/").font(.title).fontWeight(.light).foregroundColor(.white)
                    
                    ZoomViewTypeView(zoomType: .two)
                    
                    Text("/").font(.title).fontWeight(.light).foregroundColor(.white)
                    
                    ZoomViewTypeView(zoomType: .four)
                }
            }.scrollablePanel()
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
    }
    
    struct ContactPanel: View {
        var body: some View {
            VStack {
                Text("Thanks")
                    .title()
                Text("Hellride image by upklyak from Freepik")
                    .headline()
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