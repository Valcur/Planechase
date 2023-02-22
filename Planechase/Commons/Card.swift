//
//  Card.swift
//  Planechase
//
//  Created by Loic D on 20/02/2023.
//

import SwiftUI

class Card: ObservableObject {    
    var id: String
    var image: UIImage?
    var imageURL: String?
    var state: CardState
    
    init( id: String, image: UIImage? = nil, imageURL: String? = nil, state: CardState) {
        self.state = state
        self.image = image
        self.imageURL = imageURL
        self.id = id
    }
    
    func cardAppears() {
        if image == nil {
            // Find saved image or download
            let dlManager = DownloadManager(card: self, shouldImageBeSaved: true)
            
            let interval = DownloadQueue.queue.getDelayBeforeDownload(card: self)
            if interval > 0 {
                Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { timer in
                    dlManager.startDownloading() { img in
                        self.image = img
                        self.objectWillChange.send()
                    }
                }
            } else {
                dlManager.startDownloading() { img in
                    self.image = img
                    self.objectWillChange.send()
                }
            }
        }
    }
    
    func new() -> Card {
        return Card(id: self.id, image: self.image, imageURL: self.imageURL, state: self.state)
    }
    
    static func heightForWidth(_ width: CGFloat) -> CGFloat {
        // Width 12.5 for height 9
        return width * 0.72
    }
    
    static func widthtForHeight(_ height: CGFloat) -> CGFloat {
        // Width 12.5 for height 9
        return height * 1.38
    }
}

enum CardState: Int, Codable {
    case selected = 3
    case pickable = 2
    case showed = 0
    case hidden = 1
}
