//
//  ZoomViewTypeView.swift
//  Planechase
//
//  Created by Loic D on 02/06/2023.
//

import SwiftUI

extension OptionsMenuView {
    struct ZoomViewTypeView: View {
        @EnvironmentObject var planechaseVM: PlanechaseViewModel
        let zoomType: ZoomViewType
        var imageName: String {
            if zoomType == .one {
                return "square"
            } else if zoomType == .two {
                return "rectangle.grid.1x2"
            } else {
                return "square.grid.2x2"
            }
        }
        
        var body: some View {
            Button(action: {
                planechaseVM.setZoomViewType(zoomType)
            }, label: {
                Image(systemName: imageName)
                    .font(.title)
                    .foregroundColor(.white)
            }).opacity(planechaseVM.zoomViewType == zoomType ? 1 : 0.6)
        }
    }
}
