//
//  SwiftRecognitionViewController.swift
//  ClarifaiApiDemo
//

import UIKit

/**
 * This view controller performs recognition using the Clarifai API.
 */
class SwiftRecognitionViewController : UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // IMPORTANT NOTE: you should replace these keys with your own App ID and secret.
    // These can be obtained at https://developer.clarifai.com/applications
    static let appID = "vM05qo55uhZard2dL4BixmMm4WsHIl6CsGCTgS_7"
    static let appSecret = "rx4oPPiXiCWNRVcoJ0huLz02cKiQUZtq5JPVrhjM"

    // Custom Training (Alpha): to predict against a custom concept (instead of the standard
    // tag model), set this to be the name of the concept you wish to predict against. You must
    // have previously trained this concept using the same app ID and secret as above. For more
    // info on custom training, see https://github.com/Clarifai/hackathon
    static let conceptName: String? = nil
    static let conceptNamespace = "default"

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var button: UIButton!

    private lazy var client : ClarifaiClient = {
        let c = ClarifaiClient(appID: appID, appSecret: appSecret)
        // Uncomment this to request embeddings. Contact us to enable embeddings for your app:
        // c.enableEmbed = true
        return c
    }()

    @IBAction func buttonPressed(sender: UIButton) {
        // Show a UIImagePickerController to let the user pick an image from their library.
        let picker = UIImagePickerController()
        picker.sourceType = .PhotoLibrary
        picker.allowsEditing = false
        picker.delegate = self
        presentViewController(picker, animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: AnyObject]) {
        dismissViewControllerAnimated(true, completion: nil)
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            // The user picked an image. Send it Clarifai for recognition.
            imageView.image = image
            textView.text = "Recognizing..."
            button.enabled = false
            recognizeImage(image)
        }
    }

    private func recognizeImage(image: UIImage!) {
        // Scale down the image. This step is optional. However, sending large images over the
        // network is slow and does not significantly improve recognition performance.
        let size = CGSizeMake(320, 320 * image.size.height / image.size.width)
        UIGraphicsBeginImageContext(size)
        image.drawInRect(CGRectMake(0, 0, size.width, size.height))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        // Encode as a JPEG.
        let jpeg = UIImageJPEGRepresentation(scaledImage, 0.9)!

        if SwiftRecognitionViewController.conceptName == nil {
            // Standard Recognition: Send the JPEG to Clarifai for standard image tagging.
            client.recognizeJpegs([jpeg]) {
                (results: [ClarifaiResult]?, error: NSError?) in
                if error != nil {
                    print("Error: \(error)\n")
                    self.textView.text = "Sorry, there was an error recognizing your image."
                } else {
                    self.textView.text = "Tags:\n" + results![0].tags.joinWithSeparator(", ")
                }
                self.button.enabled = true
            }
        } else {
            // Custom Training: Send the JPEG to Clarifai for prediction against a custom model.
            client.predictJpegs([jpeg], conceptNamespace: SwiftRecognitionViewController.conceptNamespace, conceptName: SwiftRecognitionViewController.conceptName) {
                (results: [ClarifaiPredictionResult]?, error: NSError?) in
                if error != nil {
                    print("Error: \(error)\n")
                    self.textView.text = "Sorry, there was an error running prediction on your image."
                } else {
                    self.textView.text = "Prediction score for \(SwiftRecognitionViewController.conceptName!):\n\(results![0].score)"
                }
                self.button.enabled = true
            }
        }
    }
}
