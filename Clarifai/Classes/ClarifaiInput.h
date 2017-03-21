//
//  ClarifaiInput.h
//  ClarifaiApiDemo
//
//  Created by John Sloan on 9/1/16.
//  Copyright © 2016 Clarifai, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ClarifaiConcept.h"
#import "ClarifaiLocation.h"

/**
 * ClarifaiInputs are used to represent the inputs of an application. For example, an input can contain an image and a list of concepts (or tags) associated with this image. These can then be added to an app, used as training data for models, or searched across.
 */
@interface ClarifaiInput : NSObject

/** ID of the piece of media in your Clarifai app. */
@property (strong, nonatomic) NSString *inputID;

/** URL of the piece of media in your Clarifai app. */
@property (strong, nonatomic) NSString *mediaURL;


/** Data for media to be added to app.
 (only to be used when adding media to your app, nil otherwise) */
@property (strong, nonatomic) NSData *mediaData;

/** Time when the piece of media was added to your Clarifai app. */
@property (strong, nonatomic) NSDate *creationDate;

/** Concepts associated with this input. */
@property (strong, nonatomic) NSArray <ClarifaiConcept *> *concepts;

/** If set to true, this input can use a duplicate url of one already added to the app. Defaults to false. (only to be used when adding media to your app) */
@property BOOL allowDuplicateURLs;

/** Optionally you can set metadata for each input, which can be searched on within your app. This can be any valid json object.*/
@property (strong, nonatomic) NSDictionary *metadata;

@property (strong, nonatomic) ClarifaiLocation *location;

- (instancetype)initWithURL:(NSString *)url;
- (instancetype)initWithURL:(NSString *)URL andConcepts:(NSArray *)concepts;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end
