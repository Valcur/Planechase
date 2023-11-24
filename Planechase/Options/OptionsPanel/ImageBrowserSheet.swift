//
//  ImageBrowserSheet.swift
//  LifeCounter
//
//  Created by Loic D on 23/11/2023.
//

import SwiftUI

struct ImageBrowserSheet: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var image: UIImage?
    private var gridItemLayout: [GridItem]  {
        Array(repeating: GridItem(.flexible()), count: 3)
    }
    @State private var imagesUrl = [(String, UUID)]()
    @State var shouldBeDismissed: Bool = true
    @State var searchField: String = ""
    @State var status: SearchViewStatus = .random
    
    enum SearchViewStatus {
        case random
        case searched
        case searching
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                VStack(alignment: .leading) {
                    HStack {
                        Button(action: {
                            searchField = ""
                        }, label: {
                            Image(systemName: "xmark")
                                .font(.headline)
                                .foregroundColor(.white)
                                .buttonLabel()
                        })
                        TextField("Search", text: $searchField, onCommit: {
                            searchCards()
                        })
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 10)
                        .blurredBackground()
                        .cornerRadius(5)
                        Button(action: {
                            searchCards()
                        }, label: {
                            Text("Search")
                                .buttonLabel()
                        })
                    }.padding(10).blurredBackground()
                    if status == .random {
                        HStack {
                            Text("Random images").title()
                            Spacer()
                            Button(action: {
                                imagesUrl = []
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    iniRandomImages()
                                }
                            }, label: {
                                Image(systemName: "arrow.clockwise")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .buttonLabel()
                            })
                        }
                    } else if status == .searching {
                        Text("Searching...").title()
                    } else if status == .searched {
                        Text("Results").title()
                    }
                    LazyVGrid(columns: gridItemLayout, spacing: 10) {
                        ForEach(0..<imagesUrl.count, id: \.self) { i in
                            ImageView(imageUrl: imagesUrl[i].0,
                                      profileImage: $image,
                                      shouldBeDismissed: $shouldBeDismissed)
                            .id(imagesUrl[i].1)
                        }
                    }
                    Spacer()
                }.padding(10)
            }
            if UIDevice.isIPhone {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    Text("close".translate())
                        .textButtonLabel()
                })
            }
        }.background(Color.black.ignoresSafeArea())
        .onAppear() {
            iniRandomImages()
        }
        .onChange(of: shouldBeDismissed) { _ in
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    func iniRandomImages() {
        status = .random
        imagesUrl = []
        let randomUrl = "https://api.scryfall.com/cards/random?version=art_crop&format=image"
        for _ in 1...9 {
            imagesUrl.append((randomUrl, UUID()))
        }
    }
    
    func searchCards() {
        if searchField == "" { return }
        imagesUrl = []
        status = .searching
        let searchString = "https://api.scryfall.com/cards/search?q=\(searchField.replacingOccurrences(of: " ", with: "+"))&unique=art"
        
        if let url = URL(string: searchString) {
            let urlSession = URLSession(configuration: .default).dataTask(with: url) { (data, response, error) in
                if let error = error {
                    print(error)
                }
                
                if let data = data {
                    do {
                        let decodedData: ImageSearchQuery = try JSONDecoder().decode(ImageSearchQuery.self,
                                                                   from: data)
                        DispatchQueue.main.async {
                            if let cardData = decodedData.data {
                                self.imagesUrl = []
                                cardData.forEach {
                                    if let imageUri = $0.image_uris {
                                        if let artCrop = imageUri.art_crop {
                                            self.imagesUrl.append((artCrop, UUID()))
                                        }
                                    }
                                }
                                status = .searched
                            }
                        }
                    } catch DecodingError.keyNotFound(let key, let context) {
                        Swift.print("could not find key \(key) in JSON: \(context.debugDescription)")
                    } catch DecodingError.valueNotFound(let type, let context) {
                        Swift.print("could not find type \(type) in JSON: \(context.debugDescription)")
                    } catch DecodingError.typeMismatch(let type, let context) {
                        Swift.print("type mismatch for type \(type) in JSON: \(context.debugDescription)")
                    } catch DecodingError.dataCorrupted(let context) {
                        Swift.print("data found to be corrupted in JSON: \(context.debugDescription)")
                    } catch let error as NSError {
                        NSLog("Error in read(from:ofType:) domain= \(error.domain), description= \(error.localizedDescription)")
                    }
                }
            }
            
            urlSession.resume()
        }
    }
    
    struct ImageSearchQuery: Decodable {
        let data: [CardData]?
        
        struct CardData: Decodable {
            let image_uris: ImageUris?
        }
        
        struct ImageUris: Decodable {
            let art_crop: String?
        }
    }
    
    struct ImageView: View {
        let imageUrl: String
        @State private var image: UIImage?
        @Binding var profileImage: UIImage?
        @Binding var shouldBeDismissed: Bool
        
        var body: some View {
            Button(action: {
                chooseImage()
            }, label: {
                GeometryReader { geo in
                    ZStack {
                        if let image = image {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                        } else {
                            Color.black
                        }
                    }.frame(width: geo.size.width)
                }.frame(height: 150).cornerRadius(10).clipped()
            })
            .onAppear() {
                if image == nil {
                    if let url = URL(string: imageUrl) {
                        DispatchQueue.global().async {
                            if let data = try? Data(contentsOf: url) {
                                if let uimage = UIImage(data: data) {
                                    DispatchQueue.main.async {
                                        self.image = uimage
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        func chooseImage() {
            if let image = image {
                profileImage = image
                shouldBeDismissed.toggle()
            }
        }
    }
    

}
