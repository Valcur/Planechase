//
//  ContentManagerViewModel+Scryfall.swift
//  Planechase
//
//  Created by Loic D on 20/02/2023.
//

import Foundation

extension ContentManagerViewModel {
    func addAllPlanechaseCardsFromScryfall(_ lang: String, hdOnly: Bool) {
        Task {
            var cards = [Card]()
            for set in CardSet.getAll() {
                cards += await fetchCardsImageURLForSet(set.setCode(), lang: "en")
            }
            if lang != "en" {
                for set in CardSet.getAll() {
                    if set.setCode() != "OHOP" && set.setCode() != "OPCA" {
                        if set.setCode() == "OPC2" {
                            if !hdOnly {
                                cards += await fetchCardsImageURLForSet(set.setCode(), lang: lang)
                            }
                        } else {
                            cards += await fetchCardsImageURLForSet(set.setCode(), lang: lang)
                        }
                    }
                }
            }
    
            self.addToCollection(cards, targetLang: lang)
        }
    }
    
    func fetchCardsImageURLForSet(_ setCode: String, lang: String) async -> [Card] {
        let ulrBase = "https://api.scryfall.com/cards/search?q=lang%3A\(lang)+set%3A\(setCode)+%28type%3Aphenomenon+OR+type%3Aplane%29+&unique=prints"
        print(ulrBase)
        
        // Create URL
        guard let url = URL(string: ulrBase + setCode) else {
            print("url error for \(setCode)")
            return []
        }
        
        // Create URL session data task
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            do {
                // Parse the JSON data
                let planechaseResult = try JSONDecoder().decode(PlanechaseURLs.self, from: data)
                return self.addCardsScryfallResults(planechaseResult, setCode: setCode, lang: lang)
            } catch {
                print(error)
                return []
            }
        } catch {
            print(error)
            return []
        }
    }
    
    func addCardsScryfallResults(_ planechaseURLs: PlanechaseURLs, setCode: String, lang: String) -> [Card] {
        var cards: [Card] = []
        
        for plane in planechaseURLs.data {
            if let planeId = plane.oracleID, let planeImage = plane.imageUris.large {
                let planeLang = plane.lang ?? "en"
                var card = Card(id: planeId,
                                imageURL: planeImage,
                                state: .showed,
                                cardSets: [CardSet.cardSetForCode(setCode)],
                                cardType: CardTypeLine.typeForTypeLine(plane.typeLine),
                                cardLang: planeLang
                               )
                card = ScryfallToWizardsBridge.replaceImageUrlIfNeeded(card, lang: lang)
                cards.append(card)
            }
        }
        return cards
    }
}

extension ContentManagerViewModel {
    
    // MARK: - Welcome
    struct PlanechaseURLs: Codable {
        let object: String?
        let totalCards: Int?
        let hasMore: Bool?
        let data: [Datum]

        enum CodingKeys: String, CodingKey {
            case object
            case totalCards = "total_cards"
            case hasMore = "has_more"
            case data
        }
    }

    // MARK: - Datum
    struct Datum: Codable {
        //let object: Object
        let id, oracleID: String?
        let name: String?
        let lang: String?
        let imageUris: ImageUris
        let typeLine: String?

        enum CodingKeys: String, CodingKey {
            case id
            case oracleID = "oracle_id"
            case name, lang
            case imageUris = "image_uris"
            case typeLine = "type_line"
        }
    }

    // MARK: - ImageUris
    struct ImageUris: Codable {
        let small, normal, large: String?
        let png: String?
        let artCrop, borderCrop: String?

        enum CodingKeys: String, CodingKey {
            case small, normal, large, png
            case artCrop = "art_crop"
            case borderCrop = "border_crop"
        }
    }
}
