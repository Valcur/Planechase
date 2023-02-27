//
//  BubbleView.swift
//  Planechase
//
//  Created by Loic D on 24/02/2023.
//

import SwiftUI

struct BubbleSizes {
    static let width: CGFloat = 400
    static let discordHeight: CGFloat = 300
    static let premiumHeight: CGFloat = 380
    static let scale: CGFloat = 0.8
    static let padding: CGFloat = 15
}

struct DiscordInvite: View {
    @State var showHideDiscordAlert = false
    @State var showInvite = true
    var body: some View {
        if showInvite {
            ZStack(alignment: .topTrailing) {
                DiscordInviteBubble()
                    .padding(BubbleSizes.padding)
                    .frame(width: BubbleSizes.width, height: BubbleSizes.discordHeight)
                    .blurredBackground()
                    .scaleEffect(BubbleSizes.scale).frame(width: BubbleSizes.width * BubbleSizes.scale, height: BubbleSizes.discordHeight * BubbleSizes.scale)
                Button(action: {
                    showHideDiscordAlert = true
                }, label: {
                    Image(systemName: "xmark")
                        .font(.title)
                        .foregroundColor(.white)
                }).padding(10)
            }
            .alert(isPresented: $showHideDiscordAlert) {
                Alert(
                    title: Text("Hide Discord invite"),
                    message: Text("You can still find a link in the options under 'contact'"),
                    primaryButton: .destructive(
                        Text("Cancel"),
                        action: {showHideDiscordAlert = false}
                    ),
                    secondaryButton: .default(
                        Text("Confirm"),
                        action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showInvite = false
                            }
                        }
                    )
                )
            }
        }
    }
    
    struct DiscordInviteBubble: View {
        var imageWidth: CGFloat {
            return BubbleSizes.width - 80
        }
        var body: some View {
            Link(destination: URL(string: "https://discord.com/invite/wzm7bu6KDJ")!) {
                VStack(alignment: .leading, spacing: 20) {
                    Image("Discord")
                        .resizable()
                        .frame(width: imageWidth, height: imageWidth * 0.27)
                    
                    Text("Join us on Discord").title()
                    
                    Text("Share your custom Planechase cards or find new ones in our Discord server.").headline()
                    
                    Text("Tap here to join").headline()
                }
            }
        }
    }
}

struct GoingPremium: View {
    @EnvironmentObject var planechaseVM: PlanechaseViewModel
    @State var showHideDiscordAlert = false
    var showBubble: Bool {
        return !planechaseVM.isPremium
    }
    var body: some View {
        if showBubble {
            ZStack(alignment: .topTrailing) {
                GoingPremiumBubble()
                    .padding(BubbleSizes.padding)
                    .frame(width: BubbleSizes.width, height: BubbleSizes.premiumHeight)
                    .blurredBackground()
                    .scaleEffect(BubbleSizes.scale)
                    .frame(width: BubbleSizes.width * BubbleSizes.scale, height: BubbleSizes.premiumHeight * BubbleSizes.scale)
            }
        }
    }
    
    struct GoingPremiumBubble: View {
        @EnvironmentObject var planechaseVM: PlanechaseViewModel
        @State var showingBuyInfo = false
        @State var price = "Unknow"
        
        var body: some View {
            VStack(alignment: .leading, spacing: 20) {
                Text("Support the app").title()
                
                Text("- Separate your collection in up to 10 different decks \n- Change the background color \n- My deepest thanks").headline()
                
                HStack(spacing: 10) {
                    Image(systemName: "cart")
                        .font(.subheadline)
                        .foregroundColor(.white)
                    
                    Button(action: {
                        showingBuyInfo = true
                    }, label: {
                        HStack(spacing: 0) {
                            Text(price)
                                .headline()
                            
                            Text(" / Month")
                                .headline()
                        }.buttonLabel()
                    })
                    .onAppear() {
                        price = IAPManager.shared.price() ?? "Unknow"
                        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                            // STOP WHEN PRICE IS FOUND ?
                            if self.price == "Unknow" {
                                price = IAPManager.shared.price() ?? "Unknow"
                            }
                        }
                    }
                    .alert(isPresented: $showingBuyInfo) {
                        Alert(
                            title: Text("Subscription information"),
                            message: Text("You may purchase an auto-renewing subscription through an In-App Purchase.\n\n • (in USD) Premium - 1 month ($1.99) \n\n • Your subscription will be charged to your iTunes account at confirmation of purchase and will automatically renew (at the duration selected) unless auto-renew is turned off at least 24 hours before the end of the current period.\n\n • Current subscription may not be cancelled during the active subscription period; however, you can manage your subscription and/or turn off auto-renewal by visiting your iTunes Account Settings after purchase\n\n • Being Premium will give you, for the duration of your subsription, XXXXX."),
                            primaryButton: .destructive(
                                Text("Cancel"),
                                action: {showingBuyInfo = false}
                            ),
                            secondaryButton: .default(
                                Text("Continue"),
                                action: {
                                    planechaseVM.buy()
                                }
                            )
                        )
                    }
                }
                
                HStack(spacing: 10) {
                   Text("Already premium ? ")
                       .headline()
                   
                   Button(action: {
                       planechaseVM.restore()
                   }, label: {
                       Text("Restore")
                           .textButtonLabel()
                   })
               }
                
                HStack(spacing: 0) {
                    Text("View our ")
                        .foregroundColor(.white)
                    
                    Link("Privacy policy",
                          destination: URL(string: "http://www.burning-beard.com/against-the-horde-app-policy")!).foregroundColor(.blue)
                    
                    Text(", ")
                        .foregroundColor(.white)
                    
                    Link("EULA",
                          destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!).foregroundColor(.blue)
                }
            }
        }
    }
}
