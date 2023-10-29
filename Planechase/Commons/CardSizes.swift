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
    static let deckController = CardSize(width: 440, coeff: 0.85)
    static let selectionBorderAdditionalCornerRadius: CGFloat = 5
    
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
                return CardSizes.cornerRadiusForWidth(iPadWidth)
            }
            return CardSizes.cornerRadiusForWidth(iPadWidth) * iPhoneSizeCoeff
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
            self.iPadHeight = CardSizes.heightForWidth(width)
            self.iPhoneSizeCoeff = coeff
        }
    }
    
    static func heightForWidth(_ width: CGFloat) -> CGFloat {
        // Width 12.5 for height 9
        return width * 0.72
    }
    
    static func widthtForHeight(_ height: CGFloat) -> CGFloat {
        // Width 12.5 for height 9
        return height * 1.38
    }
    
    static func cornerRadiusForWidth(_ width: CGFloat) -> CGFloat {
        return width / 21
    }
    
    static func classic_widthForHeight(_ height: CGFloat) -> CGFloat {
        // Width 6.3 for height 8.8
        return height * 0.72
    }
    
    static func classic_cornerRadiusForHeight(_ width: CGFloat) -> CGFloat {
        return width / 22
    }
}
