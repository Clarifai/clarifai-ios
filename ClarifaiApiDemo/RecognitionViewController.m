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


/**
 * This view controller performs recognition using the Clarifai API.
 */
@interface RecognitionViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) ClarifaiClient *client;
@end


@implementation RecognitionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.imageView.image = self.image;
    self.textView.text = @"Recognizing...";

    // Resize the image. This step is optional, but we don't need to send full resolution image
    // for recognition, and it would slow things down to send a large image over the network.
    CGSize size = CGSizeMake(320, 320 * self.image.size.height / self.image.size.width);
    UIGraphicsBeginImageContext(size);
    [self.image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    // Encode as a JPEG.
    NSData *jpeg = UIImageJPEGRepresentation(scaledImage, 0.9);

    // Send to Clarifai!
    self.client = [[ClarifaiClient alloc] initWithAppID:kAppID appSecret:kAppSecret];
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
    }];
}

@end
