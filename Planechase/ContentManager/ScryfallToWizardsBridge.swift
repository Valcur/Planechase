//
//  ScryfallToWizardsBridge.swift
//  Planechase
//
//  Created by Loic D on 04/03/2024.
//

import Foundation

class ScryfallToWizardsBridge {
    // If Scryfall print resolution is too low, return the url of the card from Wizards
    // If not, return the entry url
    static func replaceImageUrlIfNeeded(_ card: Card, lang: String) -> Card {
        if lang == "en" { return card }
        var newUrl = card.imageURL
        
        switch card.id {
        case "93b3acc1-2d41-4f5f-9225-7a30ea2d8158":
            // Hauts du Logogriphe
            newUrl = wizardUrl(id: "8b6e98b4a4", lang: lang)
        case "4eebfaf3-18da-4661-b6a5-d874585e170a":
            // Esper
            newUrl = wizardUrl(id: "68201ee9d4", lang: lang)
        case "a7c6b72c-f9ec-4048-8e4c-99210e4e7b85":
            // Ghirapur
            newUrl = wizardUrl(id: "0f507e9239", lang: lang)
        case "61c5f2cb-f39c-487c-9786-a8dad4663f4f":
            // Inys Haen
            newUrl = wizardUrl(id: "6bdc7278c8", lang: lang)
        case "f3b27908-ca10-4793-ab8e-6639c73cfadd":
            // Ketria
            newUrl = wizardUrl(id: "a36ca1e766", lang: lang)
        case "0ff2bbed-e435-4108-b02a-564a75abba40":
            // Littjara
            newUrl = wizardUrl(id: "fc9efd6882", lang: lang)
        case "c907333b-eae8-444f-9da3-b193289f19e2":
            // Jungle de mégaflore
            newUrl = wizardUrl(id: "e766269e53", lang: lang)
        case "a2048704-0d22-435d-b819-269291f2981e":
            // Naktamon
            newUrl = wizardUrl(id: "8ab92cfb0e", lang: lang)
        case "08427dab-3874-4a29-bd63-cbd16c1d229d":
            // Nouvelle Argive
            newUrl = wizardUrl(id: "adce3eaead", lang: lang)
        case "ab72ff80-738a-4468-aecf-5d806143f791":
            // Drupe de Norn
            newUrl = wizardUrl(id: "09af268a0a", lang: lang)
        case "6552e3dd-ce35-4267-a25e-f5d4dceb8311":
            // Nyx
            newUrl = wizardUrl(id: "4d0a9d61e7", lang: lang)
        case "c5f0da12-b76f-42fb-a52e-cd09535e72fb":
            // Paliano
            newUrl = wizardUrl(id: "e97ce38e2f", lang: lang)
        case "91fe554b-13db-451d-ab25-717ab2b70649":
            // Ile du projet de Jusant
            newUrl = wizardUrl(id: "cc50e53d50", lang: lang)
        case "022e38c3-fcea-428f-a0d0-a6cca057faa3":
            // Strixhaven
            newUrl = wizardUrl(id: "fc14d011ef", lang: lang)
        case "a0cb118e-6af1-41d2-847f-d685ced2165d":
            // Montagne des Dix Sorciers
            newUrl = wizardUrl(id: "b6f64e9f80", lang: lang)
        case "86534917-5d51-4eba-9bf5-f9fc93c83c80":
            // Caldaia
            newUrl = wizardUrl(id: "8cfbd6310e", lang: lang)
        case "2f3e71b6-0fd6-4ac5-a265-faaabe21177b":
            // Les terres fertiles de Saulvinia
            newUrl = wizardUrl(id: "b45994c266", lang: lang)
        case "3c200cc0-02b1-4a32-a910-5cd3c4d716b7":
            // La cité d'or d'Orazca
            newUrl = wizardUrl(id: "99ffee1ba0", lang: lang)
        case "00f00001-bd84-4dbf-a707-f4b1549100d4":
            // Le grand aérain
            newUrl = wizardUrl(id: "ce7c2f4146", lang: lang)
        case "b60e8617-fc35-4c8a-beb0-4688b88484c4":
            // La fosse
            newUrl = wizardUrl(id: "3dfec8472a", lang: lang)
        case "4abae901-eb47-4318-bf64-322a893c2833":
            // La nuée Occidentale
            newUrl = wizardUrl(id: "67144ea9de", lang: lang)
        case "cb7ae16a-9982-4782-9e20-07bb771d0601":
            // Les friches
            newUrl = wizardUrl(id: "ba32330469", lang: lang)
        case "0c1cb8e2-8ed4-4a0e-926b-4df5466c607c":
            // Towashi
            newUrl = wizardUrl(id: "4dfd25f938", lang: lang)
        case "503fcc43-dafd-484b-a97f-bbd11eed66de":
            // Unyaro
            newUrl = wizardUrl(id: "280c613b1b", lang: lang)
        case "61b5984a-de6a-4d5a-8b20-e2fb3b553a34":
            // Lice de la Bravoure
            newUrl = wizardUrl(id: "810b057a4f", lang: lang)
        default:
            newUrl = card.imageURL
        }
        
        card.imageURL = newUrl
        return card
    }
    
    private static func wizardUrl(id: String, lang: String) -> String {
        return "https://media.wizards.com/2023/mom/\(lang)_\(id).png"
    }
}
