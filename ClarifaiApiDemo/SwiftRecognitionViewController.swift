//
//  SwiftRecognitionViewController.swift
//  ClarifaiApiDemo
//

import UIKit

/**
 * This is a Swift version of RecognitionViewController.
 *
 * This code is NOT executed by default! To use this class, go into Main.storyboard and change the
 * type of the view controller from RecognitionViewController to SwiftRecognitionViewController.
 */
class SwiftRecognitionViewController : UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // IMPORTANT NOTE: you should replace these keys with your own App ID and secret.
    // These can be obtained at https://developer.clarifai.com/applications
    private let AppID = "vM05qo55uhZard2dL4BixmMm4WsHIl6CsGCTgS_7";
    private let AppSecret = "rx4oPPiXiCWNRVcoJ0huLz02cKiQUZtq5JPVrhjM";

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var button: UIButton!

    private var client : ClarifaiClient {
        get {
            let c = ClarifaiClient(appID: AppID, appSecret: AppSecret)
            // Uncomment this to request embeddings. Contact us to enable embeddings for your app:
            // c.enableEmbed = true
            return c
        }
    }

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
        // Scale down the image. This step is optional. However, sending large images is slower and
        // does not significantly affect recognition performance.
        let size = CGSizeMake(320, 320 * image.size.height / image.size.width)
        UIGraphicsBeginImageContext(size)
        image.drawInRect(CGRectMake(0, 0, size.width, size.height))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        // Encode as a JPEG.
        let jpeg = UIImageJPEGRepresentation(scaledImage, 0.9)!

        // Send the JPEG to Clarifai for recognition.
        client.recognizeJpegs([jpeg], completion: { (results: [ClarifaiResult]?, error: NSError?) in
            if (error != nil) {
                print("Error: \(error)\n")
                self.textView.text = "Sorry, there was an error recognizing the image."
            } else {
                self.textView.text = "Tags:\n" + results![0].tags.joinWithSeparator(", ")
            }
            self.button.enabled = true
        })
    }
}
