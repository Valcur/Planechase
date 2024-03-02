//
//  OptionsMenuView.swift
//  Planechase
//
//  Created by Loic D on 23/02/2023.
//

import SwiftUI
extension UISplitViewController {
    open override func viewDidLoad() {
        preferredDisplayMode = UISplitViewController.DisplayMode.oneBesideSecondary
        
        // remove sidebar button, make sidebar always appear !
       presentsWithGesture = displayMode != .oneBesideSecondary
        
    }
}
struct OptionsMenuView: View {
    @EnvironmentObject var planechaseVM: PlanechaseViewModel
    @State var selectedMenu: MenuSelection = .life
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Options")) {
                    NavigationLink(destination: LifeOptionsPanel().navigationTitle(MenuSelection.life.title())) {
                        Text(MenuSelection.life.title())
                    }
                    NavigationLink(destination: OptionsPanel().navigationTitle(MenuSelection.options.title())) {
                        Text(MenuSelection.options.title())
                    }
                    NavigationLink(destination: TreacheryOptionsPanel().navigationTitle(MenuSelection.treachery.title())) {
                        Text(MenuSelection.treachery.title())
                    }
                }
                Section(header: Text("Other")) {
                    NavigationLink(destination: RulesPanel().navigationTitle(MenuSelection.rules.title())) {
                        Text(MenuSelection.rules.title())
                    }
                    NavigationLink(destination: ContactPanel().navigationTitle(MenuSelection.contact.title())) {
                        Text(MenuSelection.contact.title())
                    }
                    NavigationLink(destination: ThanksPanel().navigationTitle(MenuSelection.thanks.title())) {
                        Text(MenuSelection.thanks.title())
                    }
                }
            }.preferredColorScheme(.dark)
        }.navigationTitle("Options")
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
    
    struct RulesPanel: View {
        @EnvironmentObject var planechaseVM: PlanechaseViewModel
        
        var body: some View {
            VStack(alignment: .leading, spacing: 30) {
                Text("options_rules_classic_Title".translate())
                    .title()
                
                VStack(alignment: .leading, spacing: 20) {
                    Text("options_rules_classic_01".translate())
                        .headline()
                    
                    Text("options_rules_classic_02".translate())
                        .headline()
                    
                    Text("options_rules_classic_03".translate())
                        .headline()
                }
                
                Text("options_rules_eternitiesMap_Title".translate())
                    .title()
                
                VStack(alignment: .leading, spacing: 20) {
                    Text("options_rules_eternitiesMap_01".translate())
                        .headline()
                    
                    Text("options_rules_eternitiesMap_02".translate())
                        .headline()
                    
                    Text("options_rules_eternitiesMap_03".translate())
                        .headline()
                    
                    Text("options_rules_eternitiesMap_04".translate())
                        .headline()
                    
                    Text("options_rules_eternitiesMap_05".translate())
                        .headline()
                }
                
                Text("options_rules_lifepointsCounter_Title".translate())
                    .title()
                
                VStack(alignment: .leading, spacing: 20) {
                    Text("options_rules_lifepointsCounter_01".translate())
                        .headline()
                    
                    Text("options_rules_lifepointsCounter_02".translate())
                        .headline()
                }
            }.scrollablePanel()
            .gradientBackground(gradientId: planechaseVM.gradientId)
        }
    }
    
    struct ContactPanel: View {
        @EnvironmentObject var planechaseVM: PlanechaseViewModel
        
        var body: some View {
            VStack(spacing: 20) {
                Text("options_contact_discord".translate())
                    .headline()
                
                Link(destination: URL(string: "https://discord.com/invite/wzm7bu6KDJ")!) {
                    VStack {
                        Text("options_contact_discordJoin".translate()).headline()
                        Image("Discord")
                            .resizable()
                            .frame(width: 280, height: 78)
                    }
                }
                
                HStack {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("options_contact_link_title".translate())
                            .title()
                        
                        Link(destination: URL(string: "https://against-the-horde.com")!) {
                            Text("options_contact_linkHordeWeb".translate()).underlinedLink()
                        }
                        Link(destination: URL(string: "https://apps.apple.com/us/app/against-the-horde/id1631351942?platform=iphone")!) {
                            Text("options_contact_linkHordeiOS".translate()).underlinedLink()
                        }
                        Link(destination: URL(string: "https://apps.apple.com/us/app/aether-mtg-life-counter/id6471500910?platform=iphone")!) {
                            Text("options_contact_linkLife".translate()).underlinedLink()
                        }
                    }
                    Spacer()
                }
            }.scrollablePanel()
            .gradientBackground(gradientId: planechaseVM.gradientId)
        }
    }
    
    struct ThanksPanel: View {
        @EnvironmentObject var planechaseVM: PlanechaseViewModel
        
        var body: some View {
            VStack(spacing: 20) {
                Text("options_thanks_wizards".translate())
                    .headline()
                    .padding(.bottom, 40)
                Text("options_thanks_planechase".translate())
                    .headline()
                Text("options_thanks_chaos".translate())
                    .headline()
                Text("options_thanks_hellride".translate())
                    .headline()
                Text("options_thanks_diceSkin1".translate())
                    .headline()
                Text("options_thanks_diceSkin2".translate())
                    .headline()
                Text("options_thanks_background".translate())
                    .headline()
                Text("options_thanks_monarch".translate())
                    .headline()
                // shield by Maniprasanth
            }.scrollablePanel()
            .gradientBackground(gradientId: planechaseVM.gradientId)
        }
    }
    
    enum MenuSelection {
        case options
        case contact
        case thanks
        case rules
        case life
        case treachery
        
        func title() -> String {
            switch self {
            case .options:
                return "options_optionsTitle".translate()
            case .contact:
                return "options_contactTitle".translate()
            case .thanks:
                return "options_thanksTitle".translate()
            case .rules:
                return "options_rulesTitle".translate()
            case .life:
                return "options_lifeTitle".translate()
            case .treachery:
                return "Treachery"
            }
        }
    }
}

struct OptionsMenuView_Previews: PreviewProvider {
    static var previews: some View {
        OptionsMenuView()
    }
}
