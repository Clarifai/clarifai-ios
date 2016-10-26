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

/**
 * A ClarifaiModel will represent a single model from your application. You can get any model saved in your app using the ClarifaiApp class. You can then use each instance to train the model, predict on inputs, or inspect model version info and training data.
 */
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
 * @warning This method is async on the server, meaning that it completes the request immediately, before the model may have finished training. To check for completion, this method polls for the training status code of the model. It will return the model version, containing a status code, to the completion handler when training has completed unless an error occured with training or the user loses internet connection. In the event that a user's internet connection is lost during polling, an error is returned, but the model may still have trained successfully on the server. Make sure to handle this case appropriately and you can always just retrain. You should also double check that the returned model version has a status code of 21100 (model trained successfully).
 *
 * @param completion      Invoked when the request completes.
 */
- (void)train:(ClarifaiModelVersionCompletion)completion;

/**
 * Predict on a set of images.
 *
 * @param images      The images to predict on.
 * @param completion  Invoked when the request completes.
 */
- (void)predictOnImages:(NSArray <ClarifaiImage *> *)images
             completion:(ClarifaiPredictionsCompletion)completion;

/**
 * List versions of the model.
 *
 * @param page            Results page to load.
 * @param resultsPerPage  Number of results to return per page.
 * @param completion      Invoked when the request completes.
 */
- (void)listVersions:(int)page
      resultsPerPage:(int)resultsPerPage
          completion:(ClarifaiModelVersionsCompletion)completion;

/**
 * Get specific version of the model.
 *
 * @param versionID       ID of the version info you want to retrieve.
 * @param completion      Invoked when the request completes.
 */
- (void)getVersion:(NSString *)versionID
        completion:(ClarifaiModelVersionCompletion)completion;

/**
 * Delete specific version of the model.
 *
 * @param versionID       ID of the version info you want to retrieve.
 * @param completion      Invoked when the request completes.
 */
- (void)deleteVersion:(NSString *)versionID
           completion:(ClarifaiRequestCompletion)completion;

/**
 * Get training inputs associated with the model.
 *
 * @param page            Results page to load.
 * @param resultsPerPage  Number of results to return per page.
 * @param completion      Invoked when the request completes.
 */
- (void)listTrainingInputs:(int)page
            resultsPerPage:(int)resultsPerPage
                completion:(ClarifaiInputsCompletion)completion;

/**
 * Get training inputs associated with a given version of the model.
 *
 * @param versionID       ID of the version you want to retrieve.
 * @param page            Results page to load.
 * @param resultsPerPage  Number of results to return per page.
 * @param completion      Invoked when the request completes.
 */
- (void)listTrainingInputsForVersion:(NSString *)versionID
                                page:(int)page
                      resultsPerPage:(int)resultsPerPage
                          completion:(ClarifaiInputsCompletion)completion;
@end
