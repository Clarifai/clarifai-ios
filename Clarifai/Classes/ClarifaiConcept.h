//
//  ClarifaiConcept.h
//  ClarifaiApiDemo
//
//  Created by John Sloan on 9/1/16.
//  Copyright © 2016 Clarifai, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ClarifaiModel;

/**
 * A ClarifaiConcept represents a tag that will be predicted from an image (or any input). You can also use this class to create your own tags when adding to inputs or creating custom models.
 */
@interface ClarifaiConcept : NSObject

/** The model that this concept is associated with. */
@property (strong, nonatomic) ClarifaiModel *model;

/** The id of the concept. */
@property (strong, nonatomic) NSString *conceptID;

/** The name of the concept. */
@property (strong, nonatomic) NSString *conceptName;

/** The id of the app that this concept is associated with. */
@property (strong, nonatomic) NSString *appID;

/** The score of the concept. This is set to true(1) or false(0) when using the concept as a training input. And it is set as a prediction probability, between 0-1, when returned with an output. */
@property (nonatomic) float score;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

// conceptID will match conceptName
- (instancetype)initWithConceptName:(NSString *)conceptName;
- (instancetype)initWithConceptID:(NSString *)conceptID;

@end
