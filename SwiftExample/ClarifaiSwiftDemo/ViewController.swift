//
//  ViewController.swift
//  ClarifaiSwiftDemo
//
//  Created by John Sloan on 3/31/17.
//  Copyright © 2017 Clarifai. All rights reserved.
//

import UIKit
import Clarifai

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var textView: UITextView!
  @IBOutlet weak var button: UIButton!
  
  var app:ClarifaiApp?
  let picker = UIImagePickerController()
  
  override func viewDidLoad() {
    super.viewDidLoad()

    app = ClarifaiApp(apiKey: "Your key goes here.")

    // Depracated, for older Clarifai Applications.
    // app = ClarifaiApp(appID: "", appSecret: "")

  }

  @IBAction func buttonPressed(_ sender: UIButton) {
    // Show a UIImagePickerController to let the user pick an image from their library.
    picker.allowsEditing = false;
    picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
    picker.delegate = self;
    present(picker, animated: true, completion: nil)
  }

  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    // The user picked an image. Send it to Clarifai for recognition.
    dismiss(animated: true, completion: nil)
    if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
      imageView.image = image
      recognizeImage(image: image)
      textView.text = "Recognizing..."
      button.isEnabled = false
    }
  }

  func recognizeImage(image: UIImage) {
    
    // Check that the application was initialized correctly.
    if let app = app {
      
      // Fetch Clarifai's general model.
      app.getModelByName("general-v1.3", completion: { (model, error) in
        
        // Create a Clarifai image from a uiimage.
        let caiImage = ClarifaiImage(image: image)!
        
        // Use Clarifai's general model to pedict tags for the given image.
        model?.predict(on: [caiImage], completion: { (outputs, error) in
          print("%@", error ?? "no error")
          guard
            let caiOuputs = outputs
          else {
            print("Predict failed")
            return
          }
          
          if let caiOutput = caiOuputs.first {
            // Loop through predicted concepts (tags), and display them on the screen.
            let tags = NSMutableArray()
            for concept in caiOutput.concepts {
              tags.add(concept.conceptName)
            }
            
            DispatchQueue.main.async {
              // Update the new tags in the UI.
              self.textView.text = String(format: "Tags:\n%@", tags.componentsJoined(by: ", "))
            }
          }
          
          DispatchQueue.main.async {
            // Reset select photo button for multiple selections.
            self.button.isEnabled = true;
          }
        })
      })
    }
  }
}

