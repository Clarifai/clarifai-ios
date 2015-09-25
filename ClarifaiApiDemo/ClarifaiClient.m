//
//  ClarifaiClient.m
//  ClarifaiApiDemo
//

#import "ClarifaiClient.h"
#import <AFNetworking.h>


#define SafeRunBlock(block, ...) block ? block(__VA_ARGS__) : nil

static NSString * const kApiBaseUrl = @"https://api.clarifai.com/v1";
static NSString * const kUploadUrl = @"https://s3.amazonaws.com/clarifai-mobile-sdk-temp-storage";
static NSString * const kConceptBaseUrl = @"https://api-alpha.clarifai.com/v1/curator/concepts";
static NSString * const kErrorDomain = @"com.clarifai.ClarifaiClient";
static NSString * const kKeyAccessToken = @"com.clarifai.ClarifaiClient.AccessToken";
static NSString * const kKeyAppID = @"com.clarifai.ClarifaiClient.AppID";
static NSString * const kKeyAccessTokenExpiration = @"com.clarifai.ClarifaiClient.AccessTokenExpiration";
static NSTimeInterval const kMinTokenLifetime = 60.0;


@implementation ClarifaiResult

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        _statusCode = dict[@"status_code"] ?: @"SERVER_ERROR";
        _statusMessage = dict[@"status_message"];
        _documentId = dict[@"docid_str"];
        NSDictionary *result = dict[@"result"];
        if (result) {
            _embed = result[@"embed"];
            _tags = result[@"tag"][@"classes"];
            _probabilities = result[@"tag"][@"probs"];
        }
    }
    return self;
}

@end


@implementation ClarifaiPredictionResult

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        _score = [dict[@"score"] doubleValue];
    }
    return self;
}

@end


/** Response to the a multiop API call. */
@interface ClarifaiMultiopResponse : NSObject
@property (strong, nonatomic) NSString *statusCode;
@property (strong, nonatomic) NSString *statusMessage;
@property (strong, nonatomic) NSArray<ClarifaiResult *> *results;
@end

@implementation ClarifaiMultiopResponse

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        NSMutableArray<ClarifaiResult *> *results = [[NSMutableArray alloc] init];
        for (NSDictionary *res in dict[@"results"]) {
            [results addObject:[[ClarifaiResult alloc] initWithDictionary:res]];
        }
        _statusCode = dict[@"status_code"];
        _statusMessage = dict[@"status_msg"];
        _results = results;
    }
    return self;
}

@end


/** Response to the a predict API call. */
@interface ClarifaiPredictResponse : NSObject
@property (strong, nonatomic) NSString *statusCode;
@property (strong, nonatomic) NSString *statusMessage;
@property (strong, nonatomic) NSArray<ClarifaiPredictionResult *> *results;
@end

@implementation ClarifaiPredictResponse

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        NSMutableArray<ClarifaiPredictionResult *> *results = [[NSMutableArray alloc] init];
        for (NSDictionary *res in dict[@"urls"]) {
            [results addObject:[[ClarifaiPredictionResult alloc] initWithDictionary:res]];
        }
        _statusCode = dict[@"status"][@"status"];
        _statusMessage = dict[@"status"][@"message"];
        _results = results;
    }
    return self;
}

@end


/** OAuth access token response. */
@interface ClarifaiAccessTokenResponse : NSObject
@property (strong, nonatomic) NSString *accessToken;
@property (assign, nonatomic) NSTimeInterval expiresIn;
@end

@implementation ClarifaiAccessTokenResponse

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        _accessToken = dict[@"access_token"];
        _expiresIn = MAX([dict[@"expires_in"] doubleValue], kMinTokenLifetime);
    }
    return self;
}

@end


@interface ClarifaiClient ()
@property (assign, nonatomic) BOOL authenticating;
@property (strong, nonatomic) AFHTTPRequestOperationManager *manager;
@property (strong, nonatomic) NSString *appID;
@property (strong, nonatomic) NSString *appSecret;
@property (strong, nonatomic) NSString *accessToken;
@property (strong, nonatomic) NSDate *accessTokenExpiration;
@end


@implementation ClarifaiClient

- (instancetype)initWithAppID:(NSString *)appID appSecret:(NSString *)appSecret {
    self = [super init];
    if (self) {
        _appID = appID;
        _appSecret = appSecret;

        // Configure AFNetworking:
        _manager = [AFHTTPRequestOperationManager manager];
        _manager.operationQueue.maxConcurrentOperationCount = 4;
        _manager.responseSerializer = [AFJSONResponseSerializer serializer];
        _manager.responseSerializer.acceptableContentTypes =
            [[NSSet alloc] initWithArray:@[@"application/json"]];
        [self loadAccessToken];
    }
    return self;
}

#pragma mark - Properties

- (void)setAccessToken:(NSString *)accessToken {
    _accessToken = accessToken;
    NSString *value = [NSString stringWithFormat:@"Bearer %@", self.accessToken];
    [self.manager.requestSerializer setValue:value forHTTPHeaderField:@"Authorization"];
}

#pragma mark - Public interface

- (void)recognizeJpegs:(NSArray<NSData *> *)jpegs
            completion:(ClarifaiRecognitionCompletion)completion {
    [self recognizeWithBodyBlock:^(id<AFMultipartFormData> formData) {
        // Construct a multipart request, with one part for each image.
        for (NSData *data in jpegs) {
            [formData appendPartWithFileData:data
                                        name:@"encoded_image"
                                    fileName:@"image.jpg"
                                    mimeType:@"image/jpeg"];
        }
    } completion:completion];
}

- (void)recognizeURLs:(NSArray<NSString *> *)urls
           completion:(ClarifaiRecognitionCompletion)completion {
    [self recognizeWithBodyBlock:^(id<AFMultipartFormData> formData) {
        for (NSString *url in urls) {
            [formData appendPartWithFormData:[url dataUsingEncoding:NSUTF8StringEncoding]
                                        name:@"url"];
        }
    } completion:completion];
}

- (void)predictJpegs:(NSArray<NSData *> *)jpegs
    conceptNamespace:(NSString *)conceptNamespace
         conceptName:(NSString *)conceptName
          completion:(ClarifaiPredictionCompletion)completion {
  // The prediction API does not support sending image bytes yet (it's coming soon!), so for now,
  // we upload to S3 temporarily and then pass the URL to the predictURLs.
  [self uploadJpegs:jpegs completion:^(NSArray<NSString *> *urls, NSError *error) {
      if (error) {
          SafeRunBlock(completion, nil, error);
      } else {
          [self predictURLs:urls conceptNamespace:conceptNamespace conceptName:conceptName
                 completion:completion];
      }
  }];
}

- (void)predictURLs:(NSArray<NSString *> *)urls
   conceptNamespace:(NSString *)conceptNamespace
        conceptName:(NSString *)conceptName
         completion:(ClarifaiPredictionCompletion)completion {
    [self ensureValidAccessToken:^(NSError *error) {
        if (error) {
            SafeRunBlock(completion, nil, error);
            return;
        }
        NSString *url = [NSString stringWithFormat:@"%@/%@/%@/predict",
                         kConceptBaseUrl, conceptNamespace ?: @"default", conceptName];
        NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
        req.HTTPMethod = @"POST";
        req.HTTPBody = [NSJSONSerialization dataWithJSONObject:@{@"urls": urls} options:0 error:nil];
        [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [req setValue:[NSString stringWithFormat:@"Bearer %@", self.accessToken]
             forHTTPHeaderField:@"Authorization"];
        AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:req];
        op.responseSerializer = [AFJSONResponseSerializer serializer];
        [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *op, id res) {
            NSArray *results = [[ClarifaiPredictResponse alloc] initWithDictionary:res].results;
            SafeRunBlock(completion, results, nil);
        } failure:^(AFHTTPRequestOperation *op, NSError *error) {
            if (op.response.statusCode >= 400) {
                error = [self errorFromHttpResponse:op];  // Generate a more informative error.
            }
            if (op.response.statusCode == 401) {
                NSLog(@"/predict: Received 401 response. Access token was revoked.");
                [self invalidateAccessToken];
                SafeRunBlock(completion, nil, error);
            } else {
                SafeRunBlock(completion, nil, error);
            }
        }];
        [op start];
    }];
}

#pragma mark -

- (void)recognizeWithBodyBlock:(void (^)(id<AFMultipartFormData> formData))bodyBlock
                    completion:(ClarifaiRecognitionCompletion)completion {
    [self ensureValidAccessToken:^(NSError *error) {
        if (error) {
            SafeRunBlock(completion, nil, error);
            return;
        }
        NSString *url = [kApiBaseUrl stringByAppendingString:@"/multiop"];
        NSDictionary *params = self.enableEmbed ? @{@"model": @"general-v1.2", @"op": @"tag,embed"}
                : @{@"model": @"general-v1.2", @"op": @"tag"};
        [self.manager POST:url parameters:params constructingBodyWithBlock:bodyBlock success:
         ^(AFHTTPRequestOperation *op, NSDictionary *res) {
             // Batch requests return a separate response for each component. Ignore the top-level
             // response and process the sub-responses if they exist.
             NSArray *results = [[ClarifaiMultiopResponse alloc] initWithDictionary:res].results;
             SafeRunBlock(completion, results, nil);
         } failure:^(AFHTTPRequestOperation *op, NSError *error) {
             if (op.response.statusCode >= 400) {
                 error = [self errorFromHttpResponse:op];  // Generate a more informative error.
             }
             if (op.response.statusCode == 401) {
                 NSLog(@"/multiop: Received 401 response. Access token was revoked.");
                 [self invalidateAccessToken];
                 SafeRunBlock(completion, nil, error);
             } else {
                 SafeRunBlock(completion, nil, error);
             }
         }];
    }];
}

- (void)uploadJpegs:(NSArray<NSData *> *)jpegs
         completion:(void (^)(NSArray<NSString *> *urls, NSError *error))completion {
    if (jpegs.count == 0) {
        SafeRunBlock(completion, @[], nil);
        return;
    }
    NSMutableArray *urls = [[NSMutableArray alloc] init];
    __block NSError *error = nil;
    __block NSInteger numResponses = 0;
    for (NSData *jpeg in jpegs) {
        NSString *url = [self randomURL];
        [urls addObject:url];
        NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
        req.HTTPMethod = @"PUT";
        req.HTTPBody = jpeg;
        NSString *contentLength = [NSString stringWithFormat:@"%d", (int)jpeg.length];
        [req addValue:contentLength forHTTPHeaderField:@"Content-Length"];
        [req addValue:@"ClarifaiClient" forHTTPHeaderField:@"User-Agent"];

        AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:req];
        [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            if (++numResponses == jpegs.count) {
                SafeRunBlock(completion, error ? nil : urls, error);
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *e) {
            if (!error) {
                error = e;
            }
            if (++numResponses == jpegs.count) {
                SafeRunBlock(completion, nil, error);
            }
        }];
        [op start];
    }
}

- (NSString *)randomURL {
    return [NSString stringWithFormat:@"%@/%08x%08x.jpg", kUploadUrl, arc4random(), arc4random()];
}

#pragma mark - Access Token Management

- (void)ensureValidAccessToken:(void (^)(NSError *error))handler {
    if (self.accessToken && self.accessTokenExpiration &&
        [self.accessTokenExpiration timeIntervalSinceNow] >= kMinTokenLifetime) {
        handler(nil);  // We have a valid access token.
    } else {
        self.authenticating = YES;
        // Send a request to the auth endpoint. See: https://developer.clarifai.com/docs/auth.
        NSDictionary *params = @{@"grant_type": @"client_credentials",
                                 @"client_id": self.appID,
                                 @"client_secret": self.appSecret};
        [self.manager POST:[kApiBaseUrl stringByAppendingString:@"/token"]
                parameters:params
                   success:^(AFHTTPRequestOperation *op, id response) {
                       ClarifaiAccessTokenResponse *res = [[ClarifaiAccessTokenResponse alloc]
                                                           initWithDictionary:response];
                       [self saveAccessToken:res];
                       self.authenticating = NO;
                       handler(nil);
                   } failure:^(AFHTTPRequestOperation *op, NSError *error) {
                       if (op.response.statusCode >= 400) {
                           error = [self errorFromHttpResponse:op];
                       }
                       self.authenticating = NO;
                       handler(error);
                   }];
    }
}

- (void)loadAccessToken {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![self.appID isEqualToString:[defaults valueForKey:kKeyAppID]]) {
        [self invalidateAccessToken];
    } else {
        self.accessToken = [defaults valueForKey:kKeyAccessToken];
        self.accessTokenExpiration = [defaults valueForKey:kKeyAccessTokenExpiration];
    }
}

- (void)saveAccessToken:(ClarifaiAccessTokenResponse *)response {
    if (response.accessToken) {
        NSDate *expiration = [NSDate dateWithTimeIntervalSinceNow:response.expiresIn];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:response.accessToken forKey:kKeyAccessToken];
        [defaults setObject:expiration forKey:kKeyAccessTokenExpiration];
        [defaults setObject:self.appID forKey:kKeyAppID];
        [defaults synchronize];
        self.accessToken = response.accessToken;
        self.accessTokenExpiration = expiration;
    }
}

- (void)invalidateAccessToken {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:kKeyAccessToken];
    [defaults removeObjectForKey:kKeyAccessTokenExpiration];
    [defaults removeObjectForKey:kKeyAppID];
    [defaults synchronize];
    self.accessToken = nil;
    self.accessTokenExpiration = nil;
}

#pragma mark -

- (NSError *)errorFromHttpResponse:(AFHTTPRequestOperation *)op {
    NSString *desc;
    if (op.responseString) {
        desc = op.responseString;
    } else {
        desc = [NSString stringWithFormat:@"HTTP Status %d", (int)op.response.statusCode];
    }
    NSString *url = [op.request.URL absoluteString];
    return [[NSError alloc] initWithDomain:kErrorDomain
                                      code:op.response.statusCode
                                  userInfo:@{@"description": desc, @"url": url}];
}

@end
