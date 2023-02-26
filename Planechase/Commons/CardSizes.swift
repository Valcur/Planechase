//
//  CardSizes.swift
//  Planechase
//
//  Created by Loic D on 22/02/2023.
//

import SwiftUI

struct CardSizes {
    static let map = CardSize(width: 320, coeff: 0.7)
    static let contentManager = CardSize(width: 450, coeff: 0.7)
    static let deckController = CardSize(width: 320, coeff: 0.7)
    
    struct CardSize {
        var width: CGFloat {
            if UIDevice.current.userInterfaceIdiom == .pad {
                return iPadWidth
            }
            return iPadWidth * iPhoneSizeCoeff
        }
        var height: CGFloat{
            if UIDevice.current.userInterfaceIdiom == .pad {
                return iPadHeight
            }
            return iPadHeight * iPhoneSizeCoeff
        }
        var cornerRadius: CGFloat {
            if UIDevice.current.userInterfaceIdiom == .pad {
                return iPadWidth / 25
            }
            return iPadWidth * iPhoneSizeCoeff / 25
        }
        
        func scaledWidth(_ scaleFactor: CGFloat) -> CGFloat {
            return width * scaleFactor
        }
        
        func scaledHeight(_ scaleFactor: CGFloat) -> CGFloat {
            return height * scaleFactor
        }
        
        func scaledRadius(_ scaleFactor: CGFloat) -> CGFloat {
            return cornerRadius * scaleFactor
        }
        
        private let iPadWidth: CGFloat
        private let iPadHeight: CGFloat
        private let iPhoneSizeCoeff: CGFloat
        
        init(width: CGFloat, coeff: CGFloat) {
            self.iPadWidth = width
            self.iPadHeight = Card.heightForWidth(width)
            self.iPhoneSizeCoeff = coeff
        }
    }
}
