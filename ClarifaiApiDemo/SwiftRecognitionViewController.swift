//
//  SwiftRecognitionViewController.swift
//  ClarifaiApiDemo
//

import UIKit

/**
 * This view controller performs recognition using the Clarifai API.
 */
class SwiftRecognitionViewController : UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var button: UIButton!

    //fileprivate lazy var client : ClarifaiApp = ClarifaiClient.createApp(clarifaiClientID, appSecret: clarifaiClientSecret)
    fileprivate lazy var app : ClarifaiApp = ClarifaiApp.init(appID: "RUm2D9QVp2xNLAE9qEYGdLVMYszAGutsuOiS4es3",
                                                          appSecret: "wGumnBX_0qHZSu_I0i0VV7fiWPVjG6QQm31dIMVH")
  
    @IBAction func buttonPressed(_ sender: UIButton) {
        // Show a UIImagePickerController to let the user pick an image from their library.
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.allowsEditing = false
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        dismiss(animated: true, completion: nil)
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            // The user picked an image. Send it to Clarifai for recognition.
          
            let size = CGSize.init(width: 320, height: 320 * image.size.height / image.size.width)
            UIGraphicsBeginImageContext(size)
            image.draw(in: CGRect.init(x: 0, y: 0, width: size.width, height: size.height))
            let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
          
            app.getModelByName("general-v1.3", completion: { model, error in
                let clarifaiImage = ClarifaiImage.init(image: scaledImage)
                model?.predict(on: [clarifaiImage!], completion: { outputs, error in
                  let output : ClarifaiOutput = outputs![0]
                  let concepts = output.concepts
                  var tags = [String]()
                  for concept in concepts! {
                    tags.append(concept.conceptName)
                  }
                  DispatchQueue.main.async {
                    self.textView.text = "Tags:\n" + tags.joined(separator: ", ")
                  }
                })
            })
            imageView.image = image
            textView.text = "Recognizing..."
            button.isEnabled = false
        }
    }
}
