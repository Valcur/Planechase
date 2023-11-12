//
//  DiceRollerView.swift
//  LifeCounter
//
//  Created by Loic D on 11/11/2023.
//

import SwiftUI

struct DiceRollerView: View {
    @State var result: Int = -2
    var body: some View {
        ZStack {
            VisualEffectView(effect: UIBlurEffect(style: .systemMaterialDark))
            
            VStack {
                Spacer()
                ResultView(result: $result)
                Spacer()
                HStack {
                    Group {
                        DiceView(dice: .d4, result: $result)
                        Spacer()
                        DiceView(dice: .d6, result: $result)
                        Spacer()
                        DiceView(dice: .d8, result: $result)
                    }
                    Spacer()
                    Group {
                        DiceView(dice: .d10, result: $result)
                        Spacer()
                        DiceView(dice: .d12, result: $result)
                        Spacer()
                        DiceView(dice: .d20, result: $result)
                    }
                }
                Spacer()
            }.padding(.horizontal, 40)
        }
    }
    
    struct ResultView: View {
        @Binding var result: Int
        @State var animationProgress: Double = 1
        var size: CGFloat {
            UIDevice.isIPhone ? 100 : 150
        }
        var body: some View {
            ZStack {
                Rectangle()
                    .foregroundColor(.white)
                    .frame(width: size, height: size)
                    .cornerRadius(10)
                    .scaleEffect(1 + animationProgress * 0.1)
                Text(result <= 0 ? "" : "\(result)")
                    .font(.system(size: 50))
                    .fontWeight(.bold)
                    .foregroundColor(.black)
            }
            .onChange(of: result) { _ in
                withAnimation(.easeInOut(duration: 0.1)) {
                    animationProgress = 0
                    if result != -1 {
                        animationProgress = 1
                    }
                }

            }
        }
    }
    
    struct DiceView: View {
        let dice: Dice
        @Binding var result: Int
        var size: CGFloat {
            UIDevice.isIPhone ? 65 : 80
        }
        var body: some View {
            Button(action: {
                result = -1
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if result == -1 {
                        result = Int.random(in: 1...dice.numberOfFace())
                    }
                }
            }, label: {
                VStack {
                    Image(dice.imageName())
                        .resizable()
                        .frame(width: size, height: size)
                    Text("\(dice.numberOfFace())")
                        .title()
                }
            })
        }
    }
}

enum Dice {
    case d4
    case d6
    case d8
    case d10
    case d12
    case d20
    
    func imageName() -> String {
        switch self {
        case .d4:
            return "d4"
        case .d6:
            return "d6"
        case .d8:
            return "d8"
        case .d10:
            return "d10"
        case .d12:
            return "d12"
        case .d20:
            return "d20"
        }
    }
    
    func numberOfFace() -> Int {
        switch self {
        case .d4:
            return 4
        case .d6:
            return 6
        case .d8:
            return 8
        case .d10:
            return 10
        case .d12:
            return 12
        case .d20:
            return 20
        }
    }
}
