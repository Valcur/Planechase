//
//  WhatsNewBubble.swift
//  Planechase
//
//  Created by Loic D on 24/03/2023.
//

import SwiftUI

struct WhatsNew: View {
    @ObservedObject var whatsNew: WhatsNewController
    @State var showHideBubbleAlert = false
    
    var body: some View {
        if whatsNew.showWhatsNew {
            ZStack(alignment: .topTrailing) {
                WhatsNewBubble()
                    .padding(BubbleSizes.padding)
                    .frame(width: BubbleSizes.width, height: BubbleSizes.whatsNewHeight)
                    .blackTransparentBackground()
                    .scaleEffect(BubbleSizes.scale).frame(width: BubbleSizes.width * BubbleSizes.scale, height: BubbleSizes.whatsNewHeight * BubbleSizes.scale)
                Button(action: {
                    showHideBubbleAlert = true
                }, label: {
                    Image(systemName: "xmark")
                        .font(.title)
                        .foregroundColor(.white)
                }).padding(10)
            }
            .alert(isPresented: $showHideBubbleAlert) {
                Alert(
                    title: Text("whatsNew_hide_title".translate()),
                    message: Text("whatsNew_hide_content".translate()),
                    primaryButton: .destructive(
                        Text("cancel".translate()),
                        action: {showHideBubbleAlert = false}
                    ),
                    secondaryButton: .default(
                        Text("confirm".translate()),
                        action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                whatsNew.showWhatsNew = false
                                UserDefaults.standard.setValue(false, forKey: whatsNew.key)
                            }
                        }
                    )
                )
            }
        }
    }
    
    struct WhatsNewBubble: View {
        @Environment(\.presentationMode) var presentationMode
        var body: some View {
            VStack(alignment: .leading, spacing: 20) {
                Text("whatsNew_title".translate()).title()
                
                Text("whatsNew_content".translate()).headline()
                
                Spacer()
                
                VStack(alignment: .center, spacing: 20) {
                    Text("whatsNew_rateUs_title".translate()).title()
                    
                    Text("whatsNew_rateUs_content".translate()).headline()
                    
                    Button(action: {
                        if let url = URL(string: "itms-apps://itunes.apple.com/app/" + "6445894290") {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                            presentationMode.wrappedValue.dismiss()
                        }
                    }, label: {
                        Text("whatsNew_rateUs_button".translate()).textButtonLabel()
                    })
                }.frame(maxWidth: .infinity)
            }
        }
    }
}

class WhatsNewController: ObservableObject {
    private let updateDate = "10/11/2023"
    let key: String
    @Published var showWhatsNew: Bool
    
    init() {
        let userDefaults = UserDefaults.standard
        key = "ShowWhatsNew?_\(updateDate)"
        userDefaults.register(
            defaults: [
                key: true
            ]
        )
        showWhatsNew = UserDefaults.standard.bool(forKey: key)
    }
}
