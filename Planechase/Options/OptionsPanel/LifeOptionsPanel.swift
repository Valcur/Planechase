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
        @State var profiles: [PlayerCustomProfileInfo] = []
        
        var body: some View {
            VStack(alignment: .leading, spacing: 15) {
                Group {
                    Text("options_life_title".translate())
                        .title()
                    
                    Toggle("options_life_useLifeCounter".translate(), isOn: $planechaseVM.lifeCounterOptions.useLifeCounter)
                        .font(.subheadline).foregroundColor(.white)
                    
                    Toggle("options_life_useCommanderDamages".translate(), isOn: $planechaseVM.lifeCounterOptions.useCommanderDamages)
                        .font(.subheadline).foregroundColor(.white)
                    
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
                    
                    HStack {
                        Text("options_autoHide".translate())
                            .headline()
                        
                        Spacer()
                        
                        MenuHideLifeCooldownView(cooldown: -1)
                        MenuHideLifeCooldownView(cooldown: 15)
                        MenuHideLifeCooldownView(cooldown: 30)
                        MenuHideLifeCooldownView(cooldown: 60)
                    }
                }
                
                Toggle("options_toggle_+/-".translate(), isOn: $planechaseVM.showPlusMinus)
                    .font(.subheadline).foregroundColor(.white)
                
                Toggle("options_toggle_bigerLifeTotal".translate(), isOn: $planechaseVM.biggerLifeTotal)
                    .font(.subheadline).foregroundColor(.white)
            
                if UIDevice.isIPhone {
                    Toggle("options_toggle_fullscreenCommanderAndCounters".translate(), isOn: $planechaseVM.fullscreenCommanderAndCounters)
                        .font(.subheadline).foregroundColor(.white)
                }
                
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
                
                if planechaseVM.lifeCounterOptions.colorPaletteId > -1 {
                    Text("options_background_style".translate())
                        .headline()
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            MenuLifeCounterBackgroundStyleChoiceView(backgroundStyleId: -1)
                            MenuLifeCounterBackgroundStyleChoiceView(backgroundStyleId: 0)
                            MenuLifeCounterBackgroundStyleChoiceView(backgroundStyleId: 1)
                            MenuLifeCounterBackgroundStyleChoiceView(backgroundStyleId: 2)
                        }.padding(10)
                    }
                }
                
                Group {
                    Text("options_monarch_title".translate())
                        .title()
                    
                    Toggle("options_monarch_toggle".translate(), isOn: $planechaseVM.lifeCounterOptions.useMonarchToken)
                        .font(.subheadline).foregroundColor(.white)
                    
                    if planechaseVM.lifeCounterOptions.useMonarchToken {
                        VStack {
                            HStack {
                                Text("options_monarch_style".translate())
                                    .headline()
                                Spacer()
                            }
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    MenuMonarchStyleChoiceView(styleId: -1)
                                    MenuMonarchStyleChoiceView(styleId: 0)
                                    //MenuMonarchStyleChoiceView(styleId: 1)
                                    MenuMonarchStyleChoiceView(styleId: 2)
                                    MenuMonarchStyleChoiceView(styleId: 3)
                                    MenuMonarchStyleChoiceView(styleId: 4)
                                }.padding(10)
                            }
                        }
                    }
                }
                
                Group {
                    Text("options_profiles_title".translate())
                        .title()
                    
                    Text("options_profiles_intro".translate())
                        .headline()
                    
                    VStack(alignment: .leading, spacing: 20) {
                        ForEach(0..<profiles.count, id: \.self) { i in
                            CustomProfileView(profileIndex: i, profiles: $profiles, profileId: profiles[i].id).id(profiles[i].id)
                        }
                        Button(action: {
                            if planechaseVM.lifeCounterProfiles.count >= 10 {
                                return
                            }
                            planechaseVM.lifeCounterProfiles.append(PlayerCustomProfileInfo(name: "\("lifepoints_player".translate()) \(planechaseVM.lifeCounterProfiles.count + 1)"))
                            planechaseVM.saveProfiles_Info()
                            profiles = planechaseVM.lifeCounterProfiles
                        }, label: {
                            Text("+")
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .frame(width: 150)
                                .buttonLabel()
                        }).opacity(planechaseVM.lifeCounterProfiles.count >= 10 ? 0 : 1)
                    }
                }
            }.scrollablePanel()
            .onChange(of: planechaseVM.lifeCounterOptions.useLifeCounter) { _ in
                planechaseVM.setLifeOptions(planechaseVM.lifeCounterOptions)
            }
            .onChange(of: planechaseVM.lifeCounterOptions.useCommanderDamages) { _ in
                planechaseVM.setLifeOptions(planechaseVM.lifeCounterOptions)
            }
            .onChange(of: planechaseVM.lifeCounterOptions.useMonarchToken) { _ in
                planechaseVM.setLifeOptions(planechaseVM.lifeCounterOptions)
            }
            .onChange(of: planechaseVM.showPlusMinus) { _ in
                planechaseVM.saveLifeToggles()
            }
            .onChange(of: planechaseVM.biggerLifeTotal) { _ in
                planechaseVM.saveLifeToggles()
            }
            .onChange(of: planechaseVM.fullscreenCommanderAndCounters) { _ in
                planechaseVM.saveLifeToggles()
            }
            .onAppear() {
                profiles = planechaseVM.lifeCounterProfiles
            }
        }
        
        struct CustomProfileView: View {
            @EnvironmentObject var planechaseVM: PlanechaseViewModel
            let profileIndex: Int
            var profile: PlayerCustomProfileInfo {
                if profileIndex < planechaseVM.lifeCounterProfiles.count {
                    return planechaseVM.lifeCounterProfiles[profileIndex]
                }
                return PlayerCustomProfileInfo()
            }
            @State var profileName = ""
            @State var showingImagePicker: Bool = false
            @State private var inputImage: UIImage?
            @State var saveChangesTimer: Timer?
            @Binding var profiles: [PlayerCustomProfileInfo]
            @State var imageView: Image?
            private let maxNameLength = 15
            let profileId: UUID
            
            var body: some View {
                HStack(spacing: 20) {
                    Button(action: {
                        showingImagePicker = true
                    }, label: {
                        if let image = imageView {
                            image
                                .resizable()
                                .scaledToFill()
                        } else {
                            ZStack {
                                Color.black.opacity(0.5)
                                Image(systemName: "square.and.arrow.up")
                                    .font(.title)
                                    .foregroundColor(.white)
                            }
                        }
                    }).frame(width: 80, height: 50).cornerRadius(8).clipped()
                        .onChange(of: inputImage) { _ in saveProfileImage() }
                        .sheet(isPresented: $showingImagePicker) {
                            ImagePicker(image: $inputImage).preferredColorScheme(.dark)
                                .ignoresSafeArea()
                        }
                    
                    TextField("", text: $profileName)
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 5)
                        .padding(.horizontal, 10)
                        .background(Color.black.opacity(0.2).cornerRadius(5))
                        .onAppear() {
                            updateImageView()
                            profileName = profile.name
                        }
                        .onChange(of: profileName) { _ in
                            if profileName.count > maxNameLength {
                                profileName = String(profileName.prefix(maxNameLength))
                            }
                            saveChangesTimer?.invalidate()
                            saveChangesTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { timer in
                                if let index = planechaseVM.lifeCounterProfiles.firstIndex(where: {$0.id == profileId}) {
                                    planechaseVM.lifeCounterProfiles[index].name = profileName
                                    planechaseVM.saveProfiles_Info()
                                }
                            }
                            profiles = planechaseVM.lifeCounterProfiles
                        }
                    
                    Button(action: {
                        saveChangesTimer?.invalidate()
                        if let index = planechaseVM.lifeCounterProfiles.firstIndex(where: {$0.id == profileId}) {
                            SaveManager.deleteOptions_LifePlayerProfile_CustomImage(profile: planechaseVM.lifeCounterProfiles[index])
                            planechaseVM.lifeCounterProfiles.remove(at: index)
                            planechaseVM.saveProfiles_Info()
                            profiles = planechaseVM.lifeCounterProfiles
                        }
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
                    planechaseVM.lifeCounterProfiles[profileIndex].customImage = inputImage
                    planechaseVM.saveProfiles_Image(index: profileIndex)
                    profiles = planechaseVM.lifeCounterProfiles
                    updateImageView()
                }
            }
            
            private func updateImageView() {
                DispatchQueue.main.async {
                    if let image = profile.customImage {
                        imageView = Image(uiImage: image)
                    }
                }
            }
            
            private func resetSaveChangesTimer() {
                saveChangesTimer?.invalidate()
                saveChangesTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { timer in
                    planechaseVM.saveProfiles_Info()
                }
            }
        }
    }
}

struct PlayerCustomProfile: Codable, Identifiable {
    var id = UUID()
    var name: String
    var lastUsedSlot: Int
    var customImageData: Data?
    
    init(name: String = "", customImageData: Data? = nil) {
        self.name = name
        self.lastUsedSlot = -1
        self.customImageData = customImageData
    }
    
    init(profile: PlayerCustomProfileInfo) {
        self.id = profile.id
        self.name = profile.name
        self.customImageData = nil
        self.lastUsedSlot = -1
    }
}

struct PlayerCustomProfileInfo: Identifiable {
    var id = UUID()
    var name: String
    var customImage: UIImage?
    
    init(name: String = "", customImage: UIImage? = nil) {
        self.name = name
        self.customImage = customImage
    }
    
    init(profileData: PlayerCustomProfile) {
        self.id = profileData.id
        self.name = profileData.name
        if let imageData = profileData.customImageData {
            if let image = UIImage(data: imageData) {
                customImage = image.compressImage(height: 500)
            }
        }
    }
}
