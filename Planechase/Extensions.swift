//
//  Extensions.swift
//  Planechase
//
//  Created by Loic D on 20/02/2023.
//

import SwiftUI

extension View {
    func coloredBackground() -> some View {
        self
        // NIENFJENJ
    }
}

extension Text {
    func buttonLabel() -> some View {
        self
            .font(.subheadline)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding()
            .background(
                VisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
                    .cornerRadius(40)
                    .shadow(color: Color.black, radius: 4, x: 0, y: 4)
            )
            .padding(5)
    }
}

extension UIImage {
    func rotate(radians: Float) -> UIImage? {
        var newSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: CGFloat(radians))).size
        // Trim off the extremely small float value to prevent core graphics from rounding it up
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        let context = UIGraphicsGetCurrentContext()!

        // Move origin to middle
        context.translateBy(x: newSize.width/2, y: newSize.height/2)
        // Rotate around middle
        context.rotate(by: CGFloat(radians))
        // Draw the image at its center
        self.draw(in: CGRect(x: -self.size.width/2, y: -self.size.height/2, width: self.size.width, height: self.size.height))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
}

struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView { UIVisualEffectView() }
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) { uiView.effect = effect }
}

struct GradientView: View {
    
    let gradient: Gradient
    
    init(gradientId: Int) {
        switch gradientId {
        case 1:
            gradient = Gradient(colors: [Color("GradientLightColor"), Color("GradientDarkColor")])
            break
        case 3:
            gradient = Gradient(colors: [Color("GradientLight3Color"), Color("GradientDark3Color")])
            break
        case 4:
            gradient = Gradient(colors: [Color("GradientLight4Color"), Color("GradientDark4Color")])
            break
        case 5:
            gradient = Gradient(colors: [Color("GradientLight5Color"), Color("GradientDark5Color")])
            break
        case 6:
            gradient = Gradient(colors: [Color("GradientLight6Color"), Color("GradientDark6Color")])
            break
        case 7:
            gradient = Gradient(colors: [Color("GradientLight7Color"), Color("GradientDark7Color")])
            break
        case 8:
            gradient = Gradient(colors: [Color("GradientLight8Color"), Color("GradientDark8Color")])
            break
        default:
            gradient = Gradient(colors: [Color("GradientLight2Color"), Color("GradientDark2Color")])
            break
        }
    }
    
    var body: some View {
        LinearGradient(gradient: gradient, startPoint: .top, endPoint: .bottom)
            .saturation(1)
            .ignoresSafeArea()
    }
}
