//
//  DownloadManager.swift
//  Planechase
//
//  Created by Loic D on 20/02/2023.
//

import Foundation

import SwiftUI

class DownloadManager: ObservableObject {
    
    @Published var data = Data()
    let card: Card

    init(card: Card, shouldImageBeSaved: Bool) {
        self.card = card
    }
    
    func startDownloading(completion: @escaping (UIImage) -> Void) {
        guard card.imageURL != nil else { return }
        
        guard let url = URL(string: card.imageURL!) else { return }
        
        self.loadData(cardName: card.id, url: url) { (data, error) in
            // Handle the loaded file data
            if error == nil {
                DispatchQueue.main.async {
                    if data != nil {
                        self.data = data! as Data
                        completion((UIImage(data: self.data) ?? UIImage(named: "NoCard")!).rotate(radians: .pi/2)!)
                    }
                }
            }
        }
    }
    
    func download(url: URL, toFile file: URL, completion: @escaping (Error?) -> Void) {
        // Download the remote URL to a file
        let task = URLSession.shared.downloadTask(with: url) {
            (tempURL, response, error) in
            // Early exit on error
            guard let tempURL = tempURL else {
                completion(error)
                return
            }

            do {
                // Remove any existing document at file
                if FileManager.default.fileExists(atPath: file.path) {
                    try FileManager.default.removeItem(at: file)
                }

                // Copy the tempURL to file
                try FileManager.default.copyItem(
                    at: tempURL,
                    to: file
                )

                //try FileManager.default.moveItem(at: tempURL, to: file)
                
                completion(nil)
            }

            // Handle potential file system errors
            catch _ {
                completion(error)
            }
        }

        // Start the download
        task.resume()
    }
    
    func loadData(cardName: String, url: URL, completion: @escaping (Data?, Error?) -> Void) {
        // Compute a path to the URL in the cache
        let documents = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
        let fileCachePath = documents.appendingPathComponent("\(cardName).png")
        // If the image exists in the cache,
        // load the image from the cache and exit
        if let data = try? Data(contentsOf: fileCachePath!) {
            completion(data, nil)
            return
        }
        
        // If the image does not exist in the cache,
        // download the image to the cache
        download(url: url, toFile: fileCachePath!) { (error) in
            let data = try? Data(contentsOf: fileCachePath!)
            completion(data, error)
        }
    }
    
    static func removeAllSavedImages() {
        let fileManager = FileManager.default
        do {
            let documentDirectoryURL = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let fileURLs = try fileManager.contentsOfDirectory(at: documentDirectoryURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            for url in fileURLs {
               try fileManager.removeItem(at: url)
            }
        } catch {
            print(error)
        }
    }
}
