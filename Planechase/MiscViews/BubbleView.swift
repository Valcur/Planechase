//
//  BubbleView.swift
//  Planechase
//
//  Created by Loic D on 24/02/2023.
//

import SwiftUI

struct BubbleSizes {
    static let width: CGFloat = 400
    static let discordHeight: CGFloat = 330
    static let premiumHeight: CGFloat = 440
    static let whatsNewHeight: CGFloat = 380
    static let scale: CGFloat = 0.8
    static let padding: CGFloat = 15
}

struct DiscordInvite: View {
    @EnvironmentObject var planechaseVM: PlanechaseViewModel
    @State var showHideDiscordAlert = false
    
    var body: some View {
        if planechaseVM.showDiscordInvite {
            ZStack(alignment: .topTrailing) {
                DiscordInviteBubble()
                    .padding(BubbleSizes.padding)
                    .frame(width: BubbleSizes.width, height: BubbleSizes.discordHeight)
                    .blackTransparentBackground()
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
                    title: Text("discord_hide_title".translate()),
                    message: Text("discord_hide_content".translate()),
                    primaryButton: .destructive(
                        Text("cancel".translate()),
                        action: {showHideDiscordAlert = false}
                    ),
                    secondaryButton: .default(
                        Text("confirm".translate()),
                        action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                planechaseVM.showDiscordInvite = false
                                UserDefaults.standard.set(false, forKey: "ShowDiscordInvite")
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
                    
                    Text("discord_title".translate()).title()
                    
                    Text("discord_content".translate()).headline()
                    
                    Text("discord_tapToJoin".translate()).headline()
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
                    .blackTransparentBackground()
                    .scaleEffect(BubbleSizes.scale)
                    .frame(width: BubbleSizes.width * BubbleSizes.scale, height: BubbleSizes.premiumHeight * BubbleSizes.scale)
            }
        }
    }
    
    struct GoingPremiumBubble: View {
        @EnvironmentObject var planechaseVM: PlanechaseViewModel
        @State var showingBuyInfoMonthly = false
        @State var showingBuyInfoLifetime = false
        @State var priceMonthly = "premium_unknown".translate()
        @State var priceLifetime = "premium_unknown".translate()
        
        var body: some View {
            VStack(alignment: .leading, spacing: 20) {
                Text("premium_title".translate()).title()
                
                Text("premium_content".translate()).headline()
                
                if !planechaseVM.paymentProcessing {
                    HStack(spacing: 10) {
                        Image(systemName: "cart")
                            .font(.subheadline)
                            .foregroundColor(.white)
                        
                        Button(action: {
                            showingBuyInfoMonthly = true
                        }, label: {
                            HStack(spacing: 0) {
                                Text(priceMonthly)
                                    .headline()
                                
                                Text("premium_month".translate())
                                    .headline()
                            }.buttonLabel()
                        })
                        .alert(isPresented: $showingBuyInfoMonthly) {
                            Alert(
                                title: Text("premium_info_title".translate()),
                                message: Text("premium_info_content".translate()),
                                primaryButton: .destructive(
                                    Text("cancel".translate()),
                                    action: {showingBuyInfoMonthly = false}
                                ),
                                secondaryButton: .default(
                                    Text("continue".translate()),
                                    action: {
                                        planechaseVM.buy(productId: IAPManager.getSubscriptionId())
                                    }
                                )
                            )
                        }
                        
                        Button(action: {
                            showingBuyInfoLifetime = true
                        }, label: {
                            HStack(spacing: 0) {
                                Text(priceLifetime)
                                    .headline()
                                
                                Text("premium_lifetime".translate())
                                    .headline()
                            }.buttonLabel()
                        })
                        .alert(isPresented: $showingBuyInfoLifetime) {
                            Alert(
                                title: Text("premium_info_title".translate()),
                                message: Text("premium_lifetime_info_content".translate()),
                                primaryButton: .destructive(
                                    Text("cancel".translate()),
                                    action: {showingBuyInfoLifetime = false}
                                ),
                                secondaryButton: .default(
                                    Text("continue".translate()),
                                    action: {
                                        planechaseVM.buy(productId: IAPManager.getLifetimeId())
                                    }
                                )
                            )
                        }
                    }
                    
                    HStack(spacing: 10) {
                        Text("premium_alreadyPremium".translate())
                            .headline()
                        
                        Button(action: {
                            planechaseVM.restore()
                        }, label: {
                            Text("premium_restore".translate())
                                .textButtonLabel()
                        })
                    }
                    .onAppear() {
                        priceMonthly = IAPManager.shared.price(forProduct: IAPManager.getSubscriptionId()) ?? "premium_unknown".translate()
                        priceLifetime = IAPManager.shared.price(forProduct: IAPManager.getLifetimeId()) ?? "premium_unknown".translate()
                        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                            // STOP WHEN PRICE IS FOUND ?
                            if self.priceMonthly == "premium_unknown".translate() || self.priceLifetime == "premium_unknown".translate() {
                                priceMonthly = IAPManager.shared.price(forProduct: IAPManager.getSubscriptionId()) ?? "premium_unknown".translate()
                                priceLifetime = IAPManager.shared.price(forProduct: IAPManager.getLifetimeId()) ?? "premium_unknown".translate()
                            }
                        }
                    }
                } else {
                    Text("Processing ...").title()
                }
                
                HStack(spacing: 0) {
                    Text("premium_viewOur".translate())
                        .foregroundColor(.white)
                    
                    Link("premium_policy".translate(),
                          destination: URL(string: "http://www.burning-beard.com/privacy-policy")!).foregroundColor(.blue)
                    
                    Text(", ")
                        .foregroundColor(.white)
                    
                    Link("EULA",
                          destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!).foregroundColor(.blue)
                }
            }
        }
    }
}
