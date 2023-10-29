//
//  Treachery.swift
//  Planechase
//
//  Created by Loic D on 17/10/2023.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

struct TreacheryPlayer {
    var role: TreacheryRole
    var cardImageName: String
    var roleUrl: String
    var QRCode: UIImage
    var isRoleRevealed: Bool
    
    init(role: TreacheryRole) {
        self.role = role
        self.isRoleRevealed = role == .leader ? true : false
        let roleData = TreacheryData.getRandomRole(role) ?? TreacheryData.TreacheryRoleData(name: "", rarity: .unco, role: .traitor)
        self.roleUrl = roleData.roleUrl
        self.cardImageName = roleData.name
        self.QRCode = UIImage()
        self.QRCode = generateQRCode(from: roleData.roleUrl)
    }
    
    func generateQRCode(from string: String) -> UIImage {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        
        filter.message = Data(string.utf8)

        if let outputImage = filter.outputImage {
            if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgimg)
            }
        }

        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
    
    static func getRandomizedRoleArray(nbrOfPlayer: Int) -> [TreacheryRole] {
        var array = [TreacheryRole]()
        if nbrOfPlayer >= 2 {
            array.append(.leader)
            array.append(.traitor)
        }
        if nbrOfPlayer >= 3 {
            array.append(.assassin)
        }
        if nbrOfPlayer >= 4 {
            array.append(.assassin)
        }
        if nbrOfPlayer >= 5 {
            array.append(.guardian)
        }
        if nbrOfPlayer >= 6 {
            array.append(.assassin)
        }
        if nbrOfPlayer >= 7 {
            array.append(.guardian)
        }
        if nbrOfPlayer >= 8 {
            array.append(.traitor)
        }
        return array.shuffled()
    }
    
    enum TreacheryRole {
        case leader
        case guardian
        case assassin
        case traitor
        
        func name() -> String {
            switch self {
            case .leader:
                return "Leader"
            case .guardian:
                return "Guardian"
            case .assassin:
                return "Assassin"
            case .traitor:
                return "Traitor"
            }
        }
    }

    class TreacheryData {
        private static let leaders = [
            TreacheryRoleData(name: "The Blood Empress", rarity: .unco, role: .leader),
            TreacheryRoleData(name: "The Chaos Bringer", rarity: .unco, role: .leader),
            TreacheryRoleData(name: "The Corrupted Regent", rarity: .unco, role: .leader),
            TreacheryRoleData(name: "The Gathering", rarity: .unco, role: .leader),
            TreacheryRoleData(name: "Her Seedborn Highness", rarity: .unco, role: .leader),
            TreacheryRoleData(name: "His Beloved Majesty", rarity: .unco, role: .leader),
            TreacheryRoleData(name: "The King over the Scrapyard", rarity: .unco, role: .leader),
            TreacheryRoleData(name: "The Old Ruler", rarity: .unco, role: .leader),
            TreacheryRoleData(name: "The Queen of Light", rarity: .unco, role: .leader),
            TreacheryRoleData(name: "The Twin Princesses", rarity: .unco, role: .leader),
            TreacheryRoleData(name: "The Void Tyrant", rarity: .unco, role: .leader)
        ]
        
        private static let guardians = [
            TreacheryRoleData(name: "The Ætherist", rarity: .unco, role: .guardian),
            /*TreacheryRoleData(name: "The Augur", rarity: .unco, role: .guardian),
            TreacheryRoleData(name: "The Bodyguard", rarity: .unco, role: .guardian),
            TreacheryRoleData(name: "The Cathar", rarity: .unco, role: .guardian),
            TreacheryRoleData(name: "The Cryomancer", rarity: .unco, role: .guardian),
            TreacheryRoleData(name: "The Flickering Mage", rarity: .unco, role: .guardian),
            TreacheryRoleData(name: "The Golem", rarity: .unco, role: .guardian),
            TreacheryRoleData(name: "The Great Martyr", rarity: .unco, role: .guardian),
            TreacheryRoleData(name: "The Hieromancer", rarity: .unco, role: .guardian),
            TreacheryRoleData(name: "The Immortal", rarity: .unco, role: .guardian),
            TreacheryRoleData(name: "The Marshal", rarity: .unco, role: .guardian),
            TreacheryRoleData(name: "The Oracle", rarity: .unco, role: .guardian),
            TreacheryRoleData(name: "The Spellsnatcher", rarity: .unco, role: .guardian),
            TreacheryRoleData(name: "The Summoner", rarity: .unco, role: .guardian),
            TreacheryRoleData(name: "The Supplier", rarity: .unco, role: .guardian),
            TreacheryRoleData(name: "The Warlock", rarity: .unco, role: .guardian)*/
        ]
        
        private static let assassins = [
            TreacheryRoleData(name: "The Ambitious Queen", rarity: .unco, role: .assassin),
            TreacheryRoleData(name: "The Beastmaster", rarity: .unco, role: .assassin),
            TreacheryRoleData(name: "The Bio-Engineer", rarity: .unco, role: .assassin),
            TreacheryRoleData(name: "The Corpse Snatcher", rarity: .unco, role: .assassin),
            TreacheryRoleData(name: "The Demon", rarity: .unco, role: .assassin),
            TreacheryRoleData(name: "The Depths Caller", rarity: .unco, role: .assassin),
            TreacheryRoleData(name: "The Madwoman", rarity: .unco, role: .assassin),
            TreacheryRoleData(name: "The Necromancer", rarity: .unco, role: .assassin),
            TreacheryRoleData(name: "The Pyromancer", rarity: .unco, role: .assassin),
            TreacheryRoleData(name: "The Rebel General", rarity: .unco, role: .assassin),
            TreacheryRoleData(name: "The Seer", rarity: .unco, role: .assassin),
            TreacheryRoleData(name: "The Shapeshifting Slayer", rarity: .unco, role: .assassin),
            TreacheryRoleData(name: "The Sigil Mage", rarity: .unco, role: .assassin),
            TreacheryRoleData(name: "The Sorceress", rarity: .unco, role: .assassin),
            TreacheryRoleData(name: "The War Shaman", rarity: .unco, role: .assassin),
            TreacheryRoleData(name: "The Witch", rarity: .unco, role: .assassin),
        ]
        
        private static let traitors = [
            TreacheryRoleData(name: "The Banisher", rarity: .unco, role: .traitor),
            TreacheryRoleData(name: "The Cleaner", rarity: .unco, role: .traitor),
            TreacheryRoleData(name: "The Ferryman", rarity: .unco, role: .traitor),
            TreacheryRoleData(name: "The Gatekeeper", rarity: .unco, role: .traitor),
            TreacheryRoleData(name: "The Grenadier", rarity: .unco, role: .traitor),
            TreacheryRoleData(name: "The Metamorph", rarity: .unco, role: .traitor),
            TreacheryRoleData(name: "The Oneiromancer", rarity: .unco, role: .traitor),
            //TreacheryRoleData(name: "The Puppet Master", rarity: .unco, role: .traitor),
            TreacheryRoleData(name: "The Reflector", rarity: .unco, role: .traitor),
            TreacheryRoleData(name: "The Time Bender", rarity: .unco, role: .traitor),
            TreacheryRoleData(name: "The Wearer of Masks", rarity: .unco, role: .traitor),
        ]
        
        static func getRandomRole(_ role: TreacheryRole) -> TreacheryRoleData? {
            switch role {
            case .leader:
                return leaders.randomElement()
            case .guardian:
                return guardians.randomElement()
            case .assassin:
                return assassins.randomElement()
            case .traitor:
                return traitors.randomElement()
            }
        }
        
        struct TreacheryRoleData {
            let roleUrl: String
            let name: String
            let rarity: Rarity
            
            init(name: String, rarity: Rarity, role: TreacheryRole) {
                var fixedName = name
                if name == "The Ætherist" {
                    fixedName = "the Ætherist"
                } else {
                    fixedName = fixedName.lowercased()
                }
                self.roleUrl = "https://mtgtreachery.net/rules/oracle/?card=\(fixedName.replacingOccurrences(of: " ", with: "-"))"
                self.name = name
                self.rarity = rarity
            }
            
            enum Rarity {
                case unco
                case rare
                case mythic
            }
        }
    }
}
