//
//  ClarifaiClient.h
//  ClarifaiApiDemo
//

@import Foundation;


/** Single result in a response from the Clarifai API. */
@interface ClarifaiResult : NSObject

/** Status of the request. See https://developer.clarifai.com/docs/status_codes */
@property (strong, nonatomic, readonly) NSString *statusCode;

/** Message providing additional status details. */
@property (strong, nonatomic, readonly) NSString *statusMessage;

/** Unique identifier for the image or video, generated based on content. */
@property (strong, nonatomic, readonly) NSString *documentId;

/** Array of NSStrings, one for each tag. */
@property (strong, nonatomic, readonly) NSArray<NSString *> *tags;

/** Parallel array of NSNumbers, representing weights for each of the tags. */
@property (strong, nonatomic, readonly) NSArray<NSNumber *> *probabilities;

/**
 * Array of NSNumbers, representing the content of the image or video in a vector space. Note that
 * this is only populated if the enableEmbed property is set to YES on ClarifaiClient.
 */
@property (strong, nonatomic, readonly) NSArray<NSNumber *> *embed;

@end


/**
 * Block invoked when image recognition completes.
 *
 * @param results array of ClarifaiResults, one for each requested image.
 * @param error   error, if any, or nil on success.
 */
typedef void (^ClarifaiRecognitionCompletion)(NSArray<ClarifaiResult *> *results, NSError *error);


/** Client for the CLarifai API. */
@interface ClarifaiClient : NSObject
/**
 * Controls whether to populate the "embed" property on ClarifaiResults. The default is NO.
 * Currently, this feature needs to be enabled on an app-by-app basis. Please contact us if you
 * would like to enable this feature for your application.
 */
@property (assign, nonatomic) BOOL enableEmbed;

/**
 * Initializes a new ClarifaiClient.
 *
 * @param appID Your application client ID from https://developer.clarifai.com/applications
 * @param appSecret Your application secret from https://developer.clarifai.com/applications
 */
- (instancetype)initWithAppID:(NSString *)appID appSecret:(NSString *)appSecret;


#pragma mark - Image Recognition

/**
 * Runs recognition on one or more JPEGs.
 *
 * @param jpegs        Array of NSData containing JPEG images to send to the server
 * @param completion   Invoked when the request completes.
 */
- (void)recognizeJpegs:(NSArray<NSData *> *)jpegs
            completion:(ClarifaiRecognitionCompletion)completion;

/**
 * Runs recognition on one or more publicly accessible URLs.
 *
 * @param urls         Array of NSStrings containing publicly accessible URLs to recognize.
 * @param completion   Invoked when the request completes.
 */
- (void)recognizeURLs:(NSArray<NSString *> *)urls
           completion:(ClarifaiRecognitionCompletion)completion;

@end
