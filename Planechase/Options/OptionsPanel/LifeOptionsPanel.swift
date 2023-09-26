//
//  LifeOptionsPanel.swift
//  Planechase
//
//  Created by Loic D on 25/09/2023.
//

import SwiftUI

extension OptionsMenuView {
    struct LifeOptionsPanel: View {
        @EnvironmentObject var planechaseVM: PlanechaseViewModel
        
        var body: some View {
            VStack(alignment: .leading, spacing: 15) {
                Group {
                    Text("options_life_title".translate())
                        .title()
                    
                    Toggle("options_life_useLifeCounter".translate(), isOn: $planechaseVM.lifeCounterOptions.useLifeCounter)
                        .font(.subheadline).foregroundColor(.white)
                    
                    Toggle("options_life_useCommanderDamages".translate(), isOn: $planechaseVM.lifeCounterOptions.useCommanderDamages)
                        .font(.subheadline).foregroundColor(.white)
                    
                    Text("options_life_colorPaletteId".translate())
                        .headline()
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            MenuLifeCounterBackgroundColorChoiceView(colorId: -1)
                            MenuLifeCounterBackgroundColorChoiceView(colorId: 0)
                            MenuLifeCounterBackgroundColorChoiceView(colorId: 1)
                            MenuLifeCounterBackgroundColorChoiceView(colorId: 2)
                            MenuLifeCounterBackgroundColorChoiceView(colorId: 3)
                        }.padding(10)
                    }
                    
                    HStack {
                        Text("options_life_nbrPlayers".translate())
                            .headline()
                        
                        Spacer()
                        
                        MenuNumberOfPlayerChoiceView(numberOfPlayers: 2)
                        MenuNumberOfPlayerChoiceView(numberOfPlayers: 3)
                        MenuNumberOfPlayerChoiceView(numberOfPlayers: 4)
                        MenuNumberOfPlayerChoiceView(numberOfPlayers: 5)
                        MenuNumberOfPlayerChoiceView(numberOfPlayers: 6)
                        if !UIDevice.isIPhone {
                            MenuNumberOfPlayerChoiceView(numberOfPlayers: 7)
                            MenuNumberOfPlayerChoiceView(numberOfPlayers: 8)
                        }
                    }
                    
                    HStack {
                        Text("options_life_startingLife".translate())
                            .headline()
                        
                        Spacer()
                        
                        MenuStartingLifeChoiceView(startingLife: 20)
                        MenuStartingLifeChoiceView(startingLife: 30)
                        MenuStartingLifeChoiceView(startingLife: 40)
                        MenuStartingLifeChoiceView(startingLife: 50)
                        MenuStartingLifeChoiceView(startingLife: 60)
                    }
                }
                
                Group {
                    Text("Profiles")
                        .title()
                    
                    Text("Save player names and bakcgorund images")
                        .headline()
                    
                    VStack(alignment: .leading, spacing: 20) {
                        ForEach(0..<planechaseVM.lifeCounterOptions.profiles.count, id: \.self) { i in
                            CustomProfileView(profileIndex: i, profiles: $planechaseVM.lifeCounterOptions.profiles).id(i)
                        }
                        Button(action: {
                            planechaseVM.lifeCounterOptions.profiles.append(PlayerCustomProfile(name: "Player \(planechaseVM.lifeCounterOptions.profiles.count + 1)"))
                            planechaseVM.setLifeOptions(planechaseVM.lifeCounterOptions)
                        }, label: {
                            Text("+")
                                .textButtonLabel()
                        })
                    }
                }
            }.scrollablePanel()
            .onChange(of: planechaseVM.lifeCounterOptions.useLifeCounter) { _ in
                planechaseVM.setLifeOptions(planechaseVM.lifeCounterOptions)
            }
            .onChange(of: planechaseVM.lifeCounterOptions.useCommanderDamages) { _ in
                planechaseVM.setLifeOptions(planechaseVM.lifeCounterOptions)
            }
        }
        
        struct CustomProfileView: View {
            @EnvironmentObject var planechaseVM: PlanechaseViewModel
            let profileIndex: Int
            @Binding var profiles: [PlayerCustomProfile]
            var profile: PlayerCustomProfile {
                if profileIndex < profiles.count {
                    return profiles[profileIndex]
                }
                return PlayerCustomProfile()
            }
            @State var profileName = ""
            @State var showingImagePicker: Bool = false
            @State private var inputImage: UIImage?
            @State var saveChangesTimer: Timer?
            
            var body: some View {
                HStack(spacing: 20) {
                    Button(action: {
                        showingImagePicker = true
                    }, label: {
                        if let imageData = profile.customImageData {
                            if let image = UIImage(data: imageData) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                            }
                        } else {
                            ZStack {
                                Color.black.opacity(0.5)
                                Image(systemName: "square.and.arrow.up")
                                    .font(.title)
                                    .foregroundColor(.white)
                            }
                        }
                    }).frame(width: 80, height: 50)
                        .onChange(of: inputImage) { _ in saveProfileImage() }
                        .sheet(isPresented: $showingImagePicker) {
                            ImagePicker(image: $inputImage).preferredColorScheme(.dark)
                        }
                    
                    TextField("Placeholder", text: $profileName)
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .onAppear() {
                            profileName = profile.name
                        }
                        .onChange(of: profileName) { _ in
                            profiles[profileIndex].name = profileName
                            resetSaveChangesTimer()
                        }
                    
                    Button(action: {
                        profiles.remove(at: profileIndex)
                    }, label: {
                        Image(systemName: "trash")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.red)
                            .padding(15)
                    })
                }.padding(10).blurredBackground()
            }
            
            private func saveProfileImage() {
                guard let inputImage = inputImage else { return }
                withAnimation(.easeInOut(duration: 0.3)) {
                    profiles[profileIndex].customImageData = inputImage.pngData()
                    planechaseVM.setLifeOptions(planechaseVM.lifeCounterOptions)
                }
            }
            
            private func resetSaveChangesTimer() {
                saveChangesTimer?.invalidate()
                saveChangesTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { timer in
                    planechaseVM.setLifeOptions(planechaseVM.lifeCounterOptions)
                }
            }
        }
    }
}

struct PlayerCustomProfile: Codable {
    var id = UUID()
    var name: String
    var lastUsedSlot: Int
    var customImageData: Data?
    
    init(name: String = "", lastUsedSlot: Int = -1, customImageData: Data? = nil) {
        self.name = name
        self.lastUsedSlot = lastUsedSlot
        self.customImageData = customImageData
    }
}
