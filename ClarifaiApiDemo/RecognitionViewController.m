//
//  RecognitionViewController.m
//  ClarifaiApiDemo
//

#import "RecognitionViewController.h"
#import "ClarifaiClient.h"


// IMPORTANT NOTE: you should replace these keys with your own App ID and secret.
// These can be obtained at https://developer.clarifai.com/applications
static NSString * const kAppID = @"vM05qo55uhZard2dL4BixmMm4WsHIl6CsGCTgS_7";
static NSString * const kAppSecret = @"rx4oPPiXiCWNRVcoJ0huLz02cKiQUZtq5JPVrhjM";


// Custom Training (Alpha): to predict against a custom concept (instead of the standard tag model),
// set this to be the name of the concept you wish to predict against. You must have previously
// trained this concept using the same app ID and secret as above. For more info on custom
// training, see https://github.com/Clarifai/hackathon
static NSString * const kConceptName = nil;
static NSString * const kConceptNamespace = @"default";


/**
 * This view controller performs recognition using the Clarifai API. This code is not run by
 * default (the Swift version is). See the README for instructions on using Objective-C.
 */
@interface RecognitionViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *button;
@property (strong, nonatomic) ClarifaiClient *client;
@end


@implementation RecognitionViewController

- (ClarifaiClient *)client {
    if (!_client) {
        _client = [[ClarifaiClient alloc] initWithAppID:kAppID appSecret:kAppSecret];
        // Uncomment this to request embeddings. Contact us to enable embeddings for your app:
        // _client.enableEmbed = YES;
    }
    return _client;
}

- (IBAction)buttonPressed:(id)sender {
    // Show a UIImagePickerController to let the user pick an image from their library.
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.allowsEditing = NO;
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self dismissViewControllerAnimated:YES completion:nil];
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    if (image) {
        // The user picked an image. Send it to Clarifai for recognition.
        self.imageView.image = image;
        self.textView.text = @"Recognizing...";
        self.button.enabled = NO;
        [self recognizeImage:image];
    }
}

- (void)recognizeImage:(UIImage *)image {
    // Scale down the image. This step is optional. However, sending large images over the
    // network is slow and does not significantly improve recognition performance.
    CGSize size = CGSizeMake(320, 320 * image.size.height / image.size.width);
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    // Encode as a JPEG.
    NSData *jpeg = UIImageJPEGRepresentation(scaledImage, 0.9);

    if (!kConceptName) {
        // Standard Recognition: Send the JPEG to Clarifai for standard image tagging.
        [self.client recognizeJpegs:@[jpeg] completion:^(NSArray *results, NSError *error) {
            // Handle the response from Clarifai. This happens asynchronously.
            if (error) {
                NSLog(@"Error: %@", error);
                self.textView.text = @"Sorry, there was an error recognizing the image.";
            } else {
                ClarifaiResult *result = results.firstObject;
                self.textView.text = [NSString stringWithFormat:@"Tags:\n%@",
                                      [result.tags componentsJoinedByString:@", "]];
            }
            self.button.enabled = YES;
        }];
    } else {
        // Custom Training: Send the JPEG to Clarifai for prediction against a custom model.
        [self.client predictJpegs:@[jpeg]
                 conceptNamespace:kConceptNamespace
                      conceptName:kConceptName
                       completion:
         ^(NSArray<ClarifaiPredictionResult *> *results, NSError *error) {
             if (error) {
                 NSLog(@"Error: %@", error);
                 self.textView.text = @"Sorry, there was an error running prediction on the image.";
             } else {
                 ClarifaiPredictionResult *result = results.firstObject;
                 self.textView.text = [NSString stringWithFormat:@"Prediction score for %@:\n%f",
                                       kConceptName, result.score];
             }
             self.button.enabled = YES;
         }];
    }
}

@end
