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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[RecognitionViewController class]]) {
        RecognitionViewController *vc = (RecognitionViewController *)segue.destinationViewController;
        vc.image = sender;
    }
}

@end
