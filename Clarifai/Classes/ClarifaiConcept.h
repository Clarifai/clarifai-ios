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

/** The language of the concept name, or the default language of the ClarifaiApp. */
@property (nonatomic) NSString *language;

/** The score of the concept. This is set to true(1) or false(0) when using the concept as a training input. And it is set as a prediction probability, between 0-1, when returned with an output. */
@property (nonatomic) float score;

/** If no ID is specified, conceptID will match conceptName. */
- (instancetype)initWithConceptName:(NSString *)conceptName;

/** If no Name is specified, conceptID will match conceptName. */
- (instancetype)initWithConceptID:(NSString *)conceptID;

/** Initializes concept with given name and ID */
- (instancetype)initWithConceptName:(NSString *)conceptName conceptID:(NSString *)conceptID;

- (instancetype)initWithDictionary:(NSDictionary *)dict;
@end
