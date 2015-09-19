//
//  InitialViewController.m
//  ClarifaiApiDemo
//

#import "InitialViewController.h"
#import "RecognitionViewController.h"


@interface InitialViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@end


/**
 * This view controller handles prompting the user to select the image, then segues to the
 * RecognitionViewController for the actual recognition. 
 */
@implementation InitialViewController

- (IBAction)selectImageButtonPressed:(id)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    picker.allowsEditing = YES;
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[RecognitionViewController class]]) {
        RecognitionViewController *vc = (RecognitionViewController *)segue.destinationViewController;
        vc.image = sender;
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self dismissViewControllerAnimated:YES completion:nil];
    UIImage *image = info[UIImagePickerControllerEditedImage];
    if (image) {
        [self performSegueWithIdentifier:@"ShowRecognition" sender:image];
    }
}

@end
