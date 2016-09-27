//
//  RecognitionViewController.m
//  ClarifaiApiDemo
//

#import "RecognitionViewController.h"
#import "ClarifaiApiDemo-Swift.h"
#import "ClarifaiApp.h"


/**
 * This view controller performs recognition using the Clarifai API. This code is not run by
 * default (the Swift version is). See the README for instructions on using Objective-C.
 */
@interface RecognitionViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *button;
@property (strong, nonatomic) ClarifaiApp *app;
@end


@implementation RecognitionViewController

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
  ClarifaiApp *app = [[ClarifaiApp alloc] initWithAppID:@"RUm2D9QVp2xNLAE9qEYGdLVMYszAGutsuOiS4es3"
                                              appSecret:@"wGumnBX_0qHZSu_I0i0VV7fiWPVjG6QQm31dIMVH"];
  
  ClarifaiImage *clarifaiImage = [[ClarifaiImage alloc] initWithImage:image];
  [app getModelByName:@"general-v1.3" completion:^(ClarifaiModel *model, NSError *error) {
    [model predictOnImages:@[clarifaiImage] completion:^(NSArray<ClarifaiOutput *> *outputs, NSError *error) {
      if (!error) {
        ClarifaiOutput *output = outputs[0];
        NSMutableArray *tags = [NSMutableArray array];
        for (ClarifaiConcept *concept in output.concepts) {
          [tags addObject:concept.conceptName];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
          self.textView.text = [NSString stringWithFormat:@"Tags:\n%@", [tags componentsJoinedByString:@", "]];
        });
      }
    }];
  }];
}

@end
