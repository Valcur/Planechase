//
//  PlanechaseVM+IAP.swift
//  Planechase
//
//  Created by Loic D on 27/02/2023.
//

import SwiftUI

extension PlanechaseViewModel {
    func testPremium() {
        if false {
            self.isPremium = true
            return
        }
        IAPManager.shared.refreshSubscriptionsStatus(callback: {
            let date = UserDefaults.standard.object(forKey: IAPManager.getSubscriptionId()) as? Date ?? Date()
            if date > Date() {
                print("IS PREMIUM UNTIL \(date)")
                self.isPremium = true
            } else {
                print("IS NOT PREMIUM SINCE \(date)")
                self.isPremium = false
                self.lostPremium()
            }
        }, failure: { error in
            print("Error \(String(describing: error))")
            if !self.isPremium {
                self.lostPremium()
            }
        })
    }
    
    func buy() {
        self.paymentProcessing = true
        if IAPManager.shared.products != nil && IAPManager.shared.products!.first != nil {
            IAPManager.shared.purchaseProduct(product: IAPManager.shared.products!.first!, success: {
                if UserDefaults.standard.object(forKey: "IsPremium") as? Bool ?? false {
                    withAnimation(.easeOut(duration: 0.3)) {
                        self.isPremium = true
                    }
                }
                self.paymentProcessing = false
            }, failure: { error in
                print("Buy Fail \(String(describing: error))")
                self.paymentProcessing = false
            })
        } else {
            self.paymentProcessing = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 10, execute: {
            self.paymentProcessing = false
        })
    }
    
    func restore() {
        self.paymentProcessing = true
        if IAPManager.shared.products != nil && IAPManager.shared.products!.first != nil {
            IAPManager.shared.restorePurchases(success: {
                if UserDefaults.standard.object(forKey: "IsPremium") as? Bool ?? false {
                    withAnimation(.easeOut(duration: 0.3)) {
                        self.isPremium = true
                    }
                }
                self.paymentProcessing = false
            }, failure: { error in
                print("Restore Fail \(String(describing: error))")
                self.paymentProcessing = false
            })
        } else {
            self.paymentProcessing = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 10, execute: {
            self.paymentProcessing = false
        })
    }
    
    private func lostPremium() {
        // Reset selected deck to 0 and background color id to 1
        print("User not premium anymore")
        UserDefaults.standard.set(false, forKey: "IsPremium")
        self.contentManagerVM.changeSelectedDeck(newDeckId: 0)
        self.setGradientId(1)
        self.setDiceOptions(DiceOptions(diceStyle: 0,
                                        diceColor: 0,
                                        numberOfFace: diceOptions.numberOfFace,
                                        useChoiceDiceFace: diceOptions.useChoiceDiceFace))
    }
}
