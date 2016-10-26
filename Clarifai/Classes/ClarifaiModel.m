//
//  ClarifaiModel.m
//  ClarifaiApiDemo
//
//  Created by John Sloan on 9/1/16.
//  Copyright © 2016 Clarifai, Inc. All rights reserved.
//

#import "ClarifaiModel.h"
#import "ClarifaiApp.h"

@interface ClarifaiModel() {
  __block BOOL finishedTrainingAttempt;
  __block double curStatus;
}
@end

@implementation ClarifaiModel

- (instancetype)initWithDictionary:(NSDictionary *)dict {
  
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss'Z'";
  
  self = [super init];
  if (self) {
    _name = dict[@"name"];
    _modelID = dict[@"id"];
    _createdAt = [dateFormatter dateFromString:dict[@"created_at"]];
    _appID = dict[@"app_id"];
    
    //init model output type
    NSString *type = dict[@"output_info"][@"type"];
    if ([type isEqualToString:@"concept"]) {
      _modelType = ClarifaiModelTypeConcept;
    } else if ([type isEqualToString:@"embed"]) {
      _modelType = ClarifaiModelTypeEmbed;
    } else if ([type isEqualToString:@"facedetect"]) {
      _modelType = ClarifaiModelTypeDetection;
    } else if ([type isEqualToString:@"cluster"]) {
      _modelType = ClarifaiModelTypeCluster;
    } else if ([type isEqualToString:@"color"]) {
      _modelType = ClarifaiModelTypeColor;
    }
    
    //init concepts array if there is any
    NSMutableArray *concepts = [[NSMutableArray alloc] init];
    for (NSDictionary *conceptDict in dict[@"output_info"][@"data"][@"concepts"]) {
      ClarifaiConcept *concept = [[ClarifaiConcept alloc] initWithDictionary:conceptDict];
      [concepts addObject:concept];
    }
    _concepts = concepts;
    
    //init output info
    _conceptsMututallyExclusive = [dict[@"output_info"][@"output_config"][@"concepts_mutually_exclusive"] boolValue];
    _closedEnvironment = [dict[@"output_info"][@"output_config"][@"closed_environment"] boolValue];
    
    //init version info
    ClarifaiModelVersion *version = [[ClarifaiModelVersion alloc] initWithDictionary:dict[@"model_version"]];
    _version = version;
  }
  return self;
}

- (void)train:(ClarifaiModelVersionCompletion)completion {
  [_app ensureValidAccessToken:^(NSError *error) {
    if (error) {
      SafeRunBlock(completion, nil, error);
      return;
    }
    finishedTrainingAttempt = NO;
    NSString *apiURL = [NSString stringWithFormat:@"%@/models/%@/versions", kApiBaseUrl, self.modelID];
    [_app.manager POST:apiURL
            parameters:nil
               success:^(AFHTTPRequestOperation *operation, id response) {
                 //update version info
                 ClarifaiModelVersion *curVersion = [[ClarifaiModelVersion alloc] initWithDictionary:response[@"model"][@"model_version"]];
                 _version = curVersion;
                 curStatus = curVersion.statusCode.doubleValue;
                 finishedTrainingAttempt = NO;
                 
                 // Training is async on the server, poll to check when training completes.
                 [self pollUntilTrained:completion];
               } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
                 completion(nil, error);
               }];
  }];
}

- (void) pollUntilTrained:(ClarifaiModelVersionCompletion)completion {
  [_app getModelByID:_modelID completion:^(ClarifaiModel *model, NSError *error) {
    @synchronized (self) {
      if (!finishedTrainingAttempt) {
        if (error == nil) {
          curStatus = model.version.statusCode.doubleValue;
          if (curStatus == 21100 || floor(curStatus/10.0) == 2111) {
            finishedTrainingAttempt = YES;
            _version = model.version;
            completion(model.version, nil);
          }
        } else {
          finishedTrainingAttempt = YES;
          completion(nil, error);
        }
      }
    }
  }];
  if (!finishedTrainingAttempt) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
      [self pollUntilTrained:completion];
    });
  }
}

- (void)predictOnImages:(NSArray <ClarifaiImage *> *)images
                 completion:(ClarifaiPredictionsCompletion)completion {
  [_app ensureValidAccessToken:^(NSError *error) {
    if (error) {
      SafeRunBlock(completion, nil, error);
      return;
    }
    NSString *apiURL = [NSString stringWithFormat:@"%@/models/%@/versions/%@/outputs", kApiBaseUrl, self.modelID, self.version.versionID];
    NSMutableArray *imagesToPredictOn = [NSMutableArray array];
    for (ClarifaiImage *image in images) {
      if (image.mediaURL) {
        [imagesToPredictOn addObject:@{@"data": @{@"image": @{@"url": image.mediaURL}}}];
      } else if (image.image) {
        NSData *imageData = UIImageJPEGRepresentation(image.image, 0.88);
        [imagesToPredictOn addObject:@{@"data": @{@"image": @{@"base64": imageData.base64Encoding}}}];
      }
    }
    NSDictionary *params = @{@"inputs": imagesToPredictOn};
    [_app.manager POST:apiURL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
      NSArray *outputsData = responseObject[@"outputs"];
      NSMutableArray *outputs = [[NSMutableArray alloc] init];
      for (int i = 0; i < outputsData.count; i++) {
        ClarifaiOutput *output = [[ClarifaiOutput alloc] initWithDictionary:outputsData[i]];
        [outputs addObject:output];
      }
      completion(outputs, nil);
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
      NSLog(@"failing");
      completion(nil, error);
    }];
  }];
}

- (void)listVersions:(int)page
      resultsPerPage:(int)resultsPerPage
          completion:(ClarifaiModelVersionsCompletion)completion {
  [_app ensureValidAccessToken:^(NSError *error) {
    if (error) {
      SafeRunBlock(completion, nil, error);
      return;
    }
    NSString *apiURL = [NSString stringWithFormat:@"%@/models/%@/versions?page=%i&per_page=%i", kApiBaseUrl, _modelID, page, resultsPerPage];
    [_app.manager GET:apiURL
           parameters:nil
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSMutableArray *versions = [NSMutableArray array];
                NSArray *versionDicts = responseObject[@"model_versions"];
                for (NSDictionary *versionDict in versionDicts) {
                  ClarifaiModelVersion *version = [[ClarifaiModelVersion alloc] initWithDictionary:versionDict];
                  [versions addObject:version];
                }
                completion(versions, nil);
              } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
                completion(nil, error);
              }];
  }];
}

- (void)getVersion:(NSString *)versionID
        completion:(ClarifaiModelVersionCompletion)completion {
  [_app ensureValidAccessToken:^(NSError *error) {
    if (error) {
      SafeRunBlock(completion, nil, error);
      return;
    }
    NSString *apiURL = [NSString stringWithFormat:@"%@/models/%@/versions/%@/", kApiBaseUrl, _modelID, versionID];
    [_app.manager GET:apiURL
           parameters:nil
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                ClarifaiModelVersion *version = [[ClarifaiModelVersion alloc] initWithDictionary:responseObject[@"model_version"]];
                completion(version, nil);
              } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
                completion(nil, error);
              }];
  }];
}

- (void)deleteVersion:(NSString *)versionID
           completion:(ClarifaiRequestCompletion)completion {
  [_app ensureValidAccessToken:^(NSError *error) {
    if (error) {
      SafeRunBlock(completion, error);
      return;
    }
    NSString *apiURL = [NSString stringWithFormat:@"%@/models/%@/versions/%@/", kApiBaseUrl, _modelID, versionID];
    [_app.manager DELETE:apiURL
              parameters:nil
                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                   completion(nil);
                 } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
                   completion(error);
                 }];
  }];
}

- (void)listTrainingInputs:(int)page
            resultsPerPage:(int)resultsPerPage
                completion:(ClarifaiInputsCompletion)completion {
  [_app ensureValidAccessToken:^(NSError *error) {
    if (error) {
      SafeRunBlock(completion, nil, error);
      return;
    }
    NSString *apiURL = [NSString stringWithFormat:@"%@/models/%@/inputs?page=%i&per_page=%i", kApiBaseUrl, _modelID, page, resultsPerPage];
    [_app.manager GET:apiURL
           parameters:nil
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSMutableArray *inputs = [NSMutableArray array];
                NSArray *inputDicts = responseObject[@"inputs"];
                for (NSDictionary *inputDict in inputDicts) {
                  ClarifaiInput *input = [[ClarifaiInput alloc] initWithDictionary:inputDict];
                  [inputs addObject:input];
                }
                completion(inputs, nil);
              } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
                completion(nil, error);
              }];
  }];
}

- (void)listTrainingInputsForVersion:(NSString *)versionID
                              page:(int)page
                    resultsPerPage:(int)resultsPerPage
                        completion:(ClarifaiInputsCompletion)completion {
  [_app ensureValidAccessToken:^(NSError *error) {
    if (error) {
      SafeRunBlock(completion, nil, error);
      return;
    }
    NSString *apiURL = [NSString stringWithFormat:@"%@/models/%@/versions/%@/inputs?page=%i&per_page=%i", kApiBaseUrl, _modelID, versionID, page, resultsPerPage];
    [_app.manager GET:apiURL
           parameters:nil
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSMutableArray *inputs = [NSMutableArray array];
                NSArray *inputDicts = responseObject[@"inputs"];
                for (NSDictionary *inputDict in inputDicts) {
                  ClarifaiInput *input = [[ClarifaiInput alloc] initWithDictionary:inputDict];
                  [inputs addObject:input];
                }
                completion(inputs, nil);
              } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
                completion(nil, error);
              }];
  }];
}


@end
