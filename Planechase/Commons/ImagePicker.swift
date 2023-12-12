//
//  ImagePicker.swift
//  Planechase
//
//  Created by Loic D on 12/12/2023.
//

import SwiftUI
import PhotosUI


struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.preferredAssetRepresentationMode = .current
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {

    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            guard !results.isEmpty else { return }

            guard let provider = results.first?.itemProvider else { return }
            
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self, completionHandler: {image, error in
                       DispatchQueue.main.async {
                           guard let image = image as? UIImage else {
                               debugPrint("Error: UIImage is nil")
                               return }
                           self.parent.image = image.compressImage()
                       }
                   })
            } else if provider.hasItemConformingToTypeIdentifier(UTType.webP.identifier) {
                provider.loadDataRepresentation(forTypeIdentifier: UTType.webP.identifier) {data, err in
                    if let data = data, let img = UIImage.init(data: data) {
                        DispatchQueue.main.async {
                            self.parent.image = img.compressImage()
                        }
                    }
                }
            }
        }
    }
}
