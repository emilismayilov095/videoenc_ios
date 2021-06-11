//
//  ImagePicker.swift
//  VideoEnc
//
//  Created by Muslim on 11.06.2021.
//

import SwiftUI
import Combine
import Foundation


final class ImagePicker : ObservableObject {
    
    static let shared : ImagePicker = ImagePicker()

    private init() {}
    let view = ImagePicker.View()
    let coordinator = ImagePicker.Coordinator()

    let willChange = PassthroughSubject<NSURL?, Never>()

    @Published var url: NSURL? = nil {
        didSet {
            if url != nil {
                willChange.send(url)
            }
        }
    }
}


extension ImagePicker {

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            guard let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? NSURL else {return}
            
            
            ImagePicker.shared.url = videoURL
            picker.dismiss(animated:true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated:true)
        }
    }


    struct View: UIViewControllerRepresentable {
        func makeCoordinator() -> Coordinator {
            ImagePicker.shared.coordinator
        }
        
        func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker.View>) -> UIImagePickerController {
            let picker = UIImagePickerController()
            picker.sourceType = .savedPhotosAlbum
            picker.mediaTypes = ["public.movie"]
            picker.delegate = context.coordinator
            return picker
        }
        
        func updateUIViewController(_ uiViewController: UIImagePickerController,
                                    context: UIViewControllerRepresentableContext<ImagePicker.View>) {
            
        }
    }
    
}
