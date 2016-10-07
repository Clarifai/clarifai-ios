//
//  ClarifaiOutput.h
//  ClarifaiApiDemo
//
//  Created by John Sloan on 9/1/16.
//  Copyright © 2016 Clarifai, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ClarifaiFace.h"
#import "ClarifaiModel.h"
#import "ClarifaiConcept.h"
#import "ClarifaiInput.h"

@interface ClarifaiOutput : NSObject

/** Predictions for the piece of media. */
@property (strong, nonatomic) NSArray <ClarifaiConcept *> *concepts;

/** Faces in the piece of media. */
@property (strong, nonatomic) NSArray <ClarifaiFace *> *faces;

/** Colors in the piece of media. */
@property (strong, nonatomic) NSArray <ClarifaiConcept *> *colors;

/** Embedding for the piece of media. */
@property (strong, nonatomic) NSArray *embedding;

/** Cluster ID. */
@property (strong, nonatomic) NSString *clusterID;

/** The input that was predicted on. */
@property (strong, nonatomic) ClarifaiInput *input;


- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end
