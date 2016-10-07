//
//  ClarifaiModel.h
//  ClarifaiApiDemo
//
//  Created by John Sloan on 9/1/16.
//  Copyright © 2016 Clarifai, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ClarifaiImage.h"
#import "ClarifaiConstants.h"
#import "ClarifaiModelVersion.h"
@class ClarifaiApp;

typedef NS_ENUM(NSInteger, ClarifaiModelType) {
    ClarifaiModelTypeConcept,
    ClarifaiModelTypeEmbed,
    ClarifaiModelTypeDetection,
    ClarifaiModelTypeCluster,
    ClarifaiModelTypeColor
};

@interface ClarifaiModel : NSObject

/** The name of the model. */
@property (strong, nonatomic) NSString *name;

/** The id of the model. */
@property (strong, nonatomic) NSString *modelID;

/** The date the model was created. */
@property (strong, nonatomic) NSDate *createdAt;

/** The id of the app that the model is contained in. */
@property (strong, nonatomic) NSString *appID;

/** The type of the model. */
@property (nonatomic) ClarifaiModelType modelType;

/** The concepts associated with the model. */
@property (strong, nonatomic) NSArray<ClarifaiConcept *> *concepts;

/** Do you expect to see more than one of the concepts in this model in the SAME image? If Yes, then conceptsMutuallyExclusive: false (default), if No, then conceptsMutuallyExclusive: true. */
@property BOOL conceptsMututallyExclusive;

/** Do you expect to run the trained model on images that do not contain ANY of the concepts in the model? If yes, closedEnvironment: false (default), if no closedEnvironment: true. */
@property BOOL closedEnvironment;

/** The version of the model. */
@property (strong, nonatomic) ClarifaiModelVersion *version;

/** A reference to the ClarifaiApp object. */
@property (strong, nonatomic) ClarifaiApp *app;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

/**
 * Train the model.
 *
 * @param completion      Invoked when the request completes.
 */
- (void)train:(ClarifaiModelCompletion)completion;

/**
 * Predict on a set of images.
 *
 * @param images      The images to predict on.
 * @param completion  Invoked when the request completes.
 */
- (void)predictOnImages:(NSArray <ClarifaiImage *> *)images
              completion:(ClarifaiPredictionsCompletion)completion;

@end
