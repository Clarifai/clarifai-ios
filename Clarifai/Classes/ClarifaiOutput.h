//
//  ClarifaiOutput.h
//  ClarifaiApiDemo
//
//  Created by John Sloan on 9/1/16.
//  Copyright © 2016 Clarifai, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ClarifaiModel.h"
#import "ClarifaiConcept.h"
#import "ClarifaiInput.h"
#import "ClarifaiOutputRegion.h"
#import "NSDictionary+Clarifai.h"

/**
 * A ClarifaiOutput is the result of a model's predictions on an input. It contains a list of the predicted concepts with corresponding scores (probabilities from 0-1) for each. It will also contain a reference to the original input that was predicted on.
 */
@interface ClarifaiOutput : NSObject

/** Predictions for the piece of media. */
@property (strong, nonatomic) NSArray <ClarifaiConcept *> *concepts;

/** Colors in the piece of media. This will only be populated when using the Clarifai Color Model. */
@property (strong, nonatomic) NSArray <ClarifaiConcept *> *colors;

/** Embedding for the piece of media. This will only be populated when using an model with embed modelType. */
@property (strong, nonatomic) NSArray *embedding;

/** Cluster ID. */
@property (strong, nonatomic) NSString *clusterID;

/** The input that was predicted on. */
@property (strong, nonatomic) ClarifaiInput *input;

/** An array of detected output regions. Some models detect specific regions with bounding boxes or localized predictions. */
@property (strong, nonatomic) NSArray<ClarifaiOutputRegion *> *regions;

/** The entire 'data' dictionary returned from the API for a model prediction. If a model type is not currently supported, this dictionary can be used for customized use cases. */
@property (strong, nonatomic) NSDictionary *responseDict;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end
