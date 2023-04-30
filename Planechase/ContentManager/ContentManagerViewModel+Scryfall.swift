//
//  ContentManagerViewModel+Scryfall.swift
//  Planechase
//
//  Created by Loic D on 20/02/2023.
//

import Foundation

extension ContentManagerViewModel {
    func addAllPlanechaseCardsFromScryfall() {
        fetchCardsImageURLForSet("OHOP")
        fetchCardsImageURLForSet("OPCA")
        fetchCardsImageURLForSet("OPC2")
        fetchCardsImageURLForSet("MOC", minCN: 47, maxCN: 71)
    }
    
    func fetchCardsImageURLForSet(_ setCode: String, minCN: Int = -1, maxCN: Int = -1) {
        let ulrBase = "https://api.scryfall.com/cards/search?q=set%3A\(setCode)+%28cn%3E%3D\(minCN >= 0 ? minCN : 0)+cn%3C%3D\(maxCN >= 0 ? maxCN : 999)%29&unique=prints"
        
        print(ulrBase)
        
        // Create URL
        guard let url = URL(string: ulrBase + setCode) else {
            print("url error for \(setCode)")
            return
        }
        
        // Create URL session data task
        URLSession.shared.dataTask(with: url) { data, _, error in
            
            if let error = error {
                print(error)
                return
            }
            
            guard let data = data else {
                print("Missing data")
                return
            }
            
            do {
                // Parse the JSON data
                let planechaseResult = try JSONDecoder().decode(PlanechaseURLs.self, from: data)
                self.addCardsScryfallResults(planechaseResult)
            } catch {
                print(error)
                return
            }
            
        }.resume()
    }
    
    func addCardsScryfallResults(_ planechaseURLs: PlanechaseURLs) {
        var cards: [Card] = []
        
        for plane in planechaseURLs.data {
            cards.append(Card(id: plane.oracleID,
                              imageURL: plane.imageUris.large,
                              state: .showed
                             ))
        }

        self.addToCollection(cards)
    }
}

extension ContentManagerViewModel {
    
    // MARK: - Welcome
    struct PlanechaseURLs: Codable {
        let object: String
        let totalCards: Int
        let hasMore: Bool
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
        let object: Object
        let id, oracleID: String
        let multiverseIDS: [Int]
        let mtgoID: Int?
        let tcgplayerID, cardmarketID: Int?
        let name: String
        let lang: Lang
        let releasedAt: String
        let uri, scryfallURI: String
        let layout: String
        let highresImage: Bool
        let imageStatus: ImageStatus
        let imageUris: ImageUris
        let manaCost: String
        let cmc: Int
        let typeLine, oracleText: String?
        let colors: [JSONAny]
        let colorIdentity, keywords: [String]
        let legalities: Legalities
        let games: [Game]
        let reserved, foil, nonfoil: Bool
        let finishes: [Finish]
        let oversized, promo, reprint, variation: Bool
        let setID: String
        let datumSet: String
        let setName: String
        let setType: SetType
        let setURI, setSearchURI, scryfallSetURI, rulingsURI: String
        let printsSearchURI: String
        let collectorNumber: String
        let digital: Bool
        let rarity: Rarity
        let cardBackID, artist: String
        let artistIDS: [String]
        let illustrationID: String
        let borderColor: BorderColor
        let frame: String
        let fullArt, textless, booster, storySpotlight: Bool
        let prices: [String: String?]
        let relatedUris: RelatedUris
        let purchaseUris: PurchaseUris
        let allParts: [AllPart]?
        let producedMana: [String]?

        enum CodingKeys: String, CodingKey {
            case object, id
            case oracleID = "oracle_id"
            case multiverseIDS = "multiverse_ids"
            case mtgoID = "mtgo_id"
            case tcgplayerID = "tcgplayer_id"
            case cardmarketID = "cardmarket_id"
            case name, lang
            case releasedAt = "released_at"
            case uri
            case scryfallURI = "scryfall_uri"
            case layout
            case highresImage = "highres_image"
            case imageStatus = "image_status"
            case imageUris = "image_uris"
            case manaCost = "mana_cost"
            case cmc
            case typeLine = "type_line"
            case oracleText = "oracle_text"
            case colors
            case colorIdentity = "color_identity"
            case keywords, legalities, games, reserved, foil, nonfoil, finishes, oversized, promo, reprint, variation
            case setID = "set_id"
            case datumSet = "set"
            case setName = "set_name"
            case setType = "set_type"
            case setURI = "set_uri"
            case setSearchURI = "set_search_uri"
            case scryfallSetURI = "scryfall_set_uri"
            case rulingsURI = "rulings_uri"
            case printsSearchURI = "prints_search_uri"
            case collectorNumber = "collector_number"
            case digital, rarity
            case cardBackID = "card_back_id"
            case artist
            case artistIDS = "artist_ids"
            case illustrationID = "illustration_id"
            case borderColor = "border_color"
            case frame
            case fullArt = "full_art"
            case textless, booster
            case storySpotlight = "story_spotlight"
            case prices
            case relatedUris = "related_uris"
            case purchaseUris = "purchase_uris"
            case allParts = "all_parts"
            case producedMana = "produced_mana"
        }
    }

    // MARK: - AllPart
    struct AllPart: Codable {
        let object, id, component, name: String
        let typeLine: String
        let uri: String

        enum CodingKeys: String, CodingKey {
            case object, id, component, name
            case typeLine = "type_line"
            case uri
        }
    }

    enum BorderColor: String, Codable {
        case black = "black"
    }

    enum Finish: String, Codable {
        case nonfoil = "nonfoil"
        case foil = "foil"
    }

    enum Game: String, Codable {
        case mtgo = "mtgo"
        case paper = "paper"
    }

    enum ImageStatus: String, Codable {
        case highresScan = "highres_scan"
        case lowres = "lowres"
    }

    // MARK: - ImageUris
    struct ImageUris: Codable {
        let small, normal, large: String
        let png: String
        let artCrop, borderCrop: String

        enum CodingKeys: String, CodingKey {
            case small, normal, large, png
            case artCrop = "art_crop"
            case borderCrop = "border_crop"
        }
    }

    enum Lang: String, Codable {
        case en = "en"
    }

    // MARK: - Legalities
    struct Legalities: Codable {
        let standard, future, historic, gladiator: String
        let pioneer, explorer, modern, legacy: String
        let pauper, vintage, penny, commander: String
        let brawl, historicbrawl, alchemy, paupercommander: String
        let duel, oldschool, premodern: String
    }

    enum Object: String, Codable {
        case card = "card"
    }

    // MARK: - PurchaseUris
    struct PurchaseUris: Codable {
        let tcgplayer, cardmarket, cardhoarder: String
    }

    enum Rarity: String, Codable {
        case common = "common"
        case uncommon = "uncommon"
        case rare = "rare"
        case mythic = "mythic"
    }

    // MARK: - RelatedUris
    struct RelatedUris: Codable {
        let gatherer: String?
        let tcgplayerInfiniteArticles, tcgplayerInfiniteDecks, edhrec: String?

        enum CodingKeys: String, CodingKey {
            case gatherer
            case tcgplayerInfiniteArticles = "tcgplayer_infinite_articles"
            case tcgplayerInfiniteDecks = "tcgplayer_infinite_decks"
            case edhrec
        }
    }

    enum SetType: String, Codable {
        case planechase = "planechase"
        case commander = "commander"
    }

    // MARK: - Encode/decode helpers

    class JSONNull: Codable, Hashable {

        public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
            return true
        }

        public var hashValue: Int {
            return 0
        }

        public init() {}

        public required init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if !container.decodeNil() {
                throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
            }
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encodeNil()
        }
    }

    class JSONCodingKey: CodingKey {
        let key: String

        required init?(intValue: Int) {
            return nil
        }

        required init?(stringValue: String) {
            key = stringValue
        }

        var intValue: Int? {
            return nil
        }

        var stringValue: String {
            return key
        }
    }

    class JSONAny: Codable {

        let value: Any

        static func decodingError(forCodingPath codingPath: [CodingKey]) -> DecodingError {
            let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Cannot decode JSONAny")
            return DecodingError.typeMismatch(JSONAny.self, context)
        }

        static func encodingError(forValue value: Any, codingPath: [CodingKey]) -> EncodingError {
            let context = EncodingError.Context(codingPath: codingPath, debugDescription: "Cannot encode JSONAny")
            return EncodingError.invalidValue(value, context)
        }

        static func decode(from container: SingleValueDecodingContainer) throws -> Any {
            if let value = try? container.decode(Bool.self) {
                return value
            }
            if let value = try? container.decode(Int64.self) {
                return value
            }
            if let value = try? container.decode(Double.self) {
                return value
            }
            if let value = try? container.decode(String.self) {
                return value
            }
            if container.decodeNil() {
                return JSONNull()
            }
            throw decodingError(forCodingPath: container.codingPath)
        }

        static func decode(from container: inout UnkeyedDecodingContainer) throws -> Any {
            if let value = try? container.decode(Bool.self) {
                return value
            }
            if let value = try? container.decode(Int64.self) {
                return value
            }
            if let value = try? container.decode(Double.self) {
                return value
            }
            if let value = try? container.decode(String.self) {
                return value
            }
            if let value = try? container.decodeNil() {
                if value {
                    return JSONNull()
                }
            }
            if var container = try? container.nestedUnkeyedContainer() {
                return try decodeArray(from: &container)
            }
            if var container = try? container.nestedContainer(keyedBy: JSONCodingKey.self) {
                return try decodeDictionary(from: &container)
            }
            throw decodingError(forCodingPath: container.codingPath)
        }

        static func decode(from container: inout KeyedDecodingContainer<JSONCodingKey>, forKey key: JSONCodingKey) throws -> Any {
            if let value = try? container.decode(Bool.self, forKey: key) {
                return value
            }
            if let value = try? container.decode(Int64.self, forKey: key) {
                return value
            }
            if let value = try? container.decode(Double.self, forKey: key) {
                return value
            }
            if let value = try? container.decode(String.self, forKey: key) {
                return value
            }
            if let value = try? container.decodeNil(forKey: key) {
                if value {
                    return JSONNull()
                }
            }
            if var container = try? container.nestedUnkeyedContainer(forKey: key) {
                return try decodeArray(from: &container)
            }
            if var container = try? container.nestedContainer(keyedBy: JSONCodingKey.self, forKey: key) {
                return try decodeDictionary(from: &container)
            }
            throw decodingError(forCodingPath: container.codingPath)
        }

        static func decodeArray(from container: inout UnkeyedDecodingContainer) throws -> [Any] {
            var arr: [Any] = []
            while !container.isAtEnd {
                let value = try decode(from: &container)
                arr.append(value)
            }
            return arr
        }

        static func decodeDictionary(from container: inout KeyedDecodingContainer<JSONCodingKey>) throws -> [String: Any] {
            var dict = [String: Any]()
            for key in container.allKeys {
                let value = try decode(from: &container, forKey: key)
                dict[key.stringValue] = value
            }
            return dict
        }

        static func encode(to container: inout UnkeyedEncodingContainer, array: [Any]) throws {
            for value in array {
                if let value = value as? Bool {
                    try container.encode(value)
                } else if let value = value as? Int64 {
                    try container.encode(value)
                } else if let value = value as? Double {
                    try container.encode(value)
                } else if let value = value as? String {
                    try container.encode(value)
                } else if value is JSONNull {
                    try container.encodeNil()
                } else if let value = value as? [Any] {
                    var container = container.nestedUnkeyedContainer()
                    try encode(to: &container, array: value)
                } else if let value = value as? [String: Any] {
                    var container = container.nestedContainer(keyedBy: JSONCodingKey.self)
                    try encode(to: &container, dictionary: value)
                } else {
                    throw encodingError(forValue: value, codingPath: container.codingPath)
                }
            }
        }

        static func encode(to container: inout KeyedEncodingContainer<JSONCodingKey>, dictionary: [String: Any]) throws {
            for (key, value) in dictionary {
                let key = JSONCodingKey(stringValue: key)!
                if let value = value as? Bool {
                    try container.encode(value, forKey: key)
                } else if let value = value as? Int64 {
                    try container.encode(value, forKey: key)
                } else if let value = value as? Double {
                    try container.encode(value, forKey: key)
                } else if let value = value as? String {
                    try container.encode(value, forKey: key)
                } else if value is JSONNull {
                    try container.encodeNil(forKey: key)
                } else if let value = value as? [Any] {
                    var container = container.nestedUnkeyedContainer(forKey: key)
                    try encode(to: &container, array: value)
                } else if let value = value as? [String: Any] {
                    var container = container.nestedContainer(keyedBy: JSONCodingKey.self, forKey: key)
                    try encode(to: &container, dictionary: value)
                } else {
                    throw encodingError(forValue: value, codingPath: container.codingPath)
                }
            }
        }

        static func encode(to container: inout SingleValueEncodingContainer, value: Any) throws {
            if let value = value as? Bool {
                try container.encode(value)
            } else if let value = value as? Int64 {
                try container.encode(value)
            } else if let value = value as? Double {
                try container.encode(value)
            } else if let value = value as? String {
                try container.encode(value)
            } else if value is JSONNull {
                try container.encodeNil()
            } else {
                throw encodingError(forValue: value, codingPath: container.codingPath)
            }
        }

        public required init(from decoder: Decoder) throws {
            if var arrayContainer = try? decoder.unkeyedContainer() {
                self.value = try JSONAny.decodeArray(from: &arrayContainer)
            } else if var container = try? decoder.container(keyedBy: JSONCodingKey.self) {
                self.value = try JSONAny.decodeDictionary(from: &container)
            } else {
                let container = try decoder.singleValueContainer()
                self.value = try JSONAny.decode(from: container)
            }
        }

        public func encode(to encoder: Encoder) throws {
            if let arr = self.value as? [Any] {
                var container = encoder.unkeyedContainer()
                try JSONAny.encode(to: &container, array: arr)
            } else if let dict = self.value as? [String: Any] {
                var container = encoder.container(keyedBy: JSONCodingKey.self)
                try JSONAny.encode(to: &container, dictionary: dict)
            } else {
                var container = encoder.singleValueContainer()
                try JSONAny.encode(to: &container, value: self.value)
            }
        }
    }

}
