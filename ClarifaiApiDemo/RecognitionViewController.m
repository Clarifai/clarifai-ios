//
//  RecognitionViewController.m
//  ClarifaiApiDemo
//

#import "RecognitionViewController.h"
#import "ClarifaiApiDemo-Swift.h"
#import "ClarifaiClient.h"


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
        _client = [[ClarifaiClient alloc] initWithAppID:[Credentials clientID] appSecret:[Credentials clientSecret]];
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

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
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

    // Send the JPEG to Clarifai for standard image tagging.
    [self.client recognizeJpegs:@[jpeg] completion:^(NSArray *results, NSError *error) {
        // Handle the response from Clarifai. This happens asynchronously.
        if (error) {
            NSLog(@"Error: %@", error);
            self.textView.text = @"Sorry, there was an error recognizing the image.";
        } else {
            ClarifaiResult *result = results.firstObject;
            self.textView.text = [NSString stringWithFormat:@"Tags:\n%@", [result.tags componentsJoinedByString:@", "]];
        }
        self.button.enabled = YES;
    }];
}

@end
