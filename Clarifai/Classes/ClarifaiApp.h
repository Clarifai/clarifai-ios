//
//  ClarifaiApp.h
//  ClarifaiApiDemo
//
//  Created by John Sloan on 9/1/16.
//  Copyright © 2016 Clarifai, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
@import AFNetworking;
#import "ClarifaiModel.h"
#import "ClarifaiSearchTerm.h"
#import "ClarifaiConcept.h"
#import "ClarifaiImage.h"
#import "ClarifaiInput.h"
#import "ClarifaiOutput.h"
#import "ClarifaiConstants.h"

typedef NS_ENUM(NSInteger, ClarifaiPredictionType) {
    ClarifaiPredictionTypeAny,
    ClarifaiPredictionTypeAll,
    ClarifaiPredictionTypeNot
};

@interface ClarifaiApp : NSObject

@property (strong, nonatomic) AFHTTPRequestOperationManager *manager;
@property (strong, nonatomic) NSString *accessToken;

/**
 * Initializes a new ClarifaiApp.
 *
 * @param appID Your application client ID from https://developer.clarifai.com/applications
 * @param appSecret Your application secret from https://developer.clarifai.com/applications
 */
- (instancetype)initWithAppID:(NSString *)appID appSecret:(NSString *)appSecret;

/**
 * Saves inputs to your Clarifai application.
 *
 * @param images       Array containing ClarifaiInputs to save to your application.
 * @param completion   Invoked when the request completes.
 */

- (void)addInputs:(NSArray <ClarifaiInput *> *)inputs completion:(ClarifaiInputsCompletion)completion;

/**
 * This can be used to add tags to an existing input.
 *
 * @param concepts      Array of new ClarifaiConcepts.
 * @param inputID       String containing the id of the input you'd like to update
 *                      concepts for.
 * @param completion    Invoked when the update completes.
 */

- (void)addConcepts:(NSArray <ClarifaiConcept *> *)concepts forInputWithID:(NSString *)inputID completion:(ClarifaiStoreInputCompletion)completion;

/**
 * This can be used to delete tags from an existing input.
 *
 * @param concepts      Array of ClarifaiConcepts to delete (these need to have matching conceptID's
 *                      to whichever ones are being deleted).
 * @param inputID       String containing the id of the input you'd like to update
 *                      concepts for.
 * @param completion    Invoked when the update completes.
 */
- (void)deleteConcepts:(NSArray <ClarifaiConcept *> *)concepts forInputWithID:(NSString *)inputID completion:(ClarifaiStoreInputCompletion)completion;

/**
 * Retrieves images that have been saved to your Clarifai application on the specified page.
 *
 * @param page         The page of images that you want to list.
 * @param pageSize     The size that you'd like pages to be.
 * @param completion   Invoked when the request completes.
 */
- (void)getInputsOnPage:(int)page pageSize:(int)pageSize completion:(ClarifaiInputsCompletion)completion;

/**
 * Retrieves a single image that has been saved by your Clarifai application.
 *
 * @param inputID      String containing the id of the image you'd like to retrieve.
 * @param completion   Invoked when the request completes.
 */
- (void)getInput:(NSString *)inuptID completion:(ClarifaiStoreInputCompletion)completion;

/**
 * Retrieves the status of all inputs in your Clarifai application.
 *
 * @param completion   Invoked when the request completes.
 */
- (void)getInputsStatus:(ClarifaiInputsStatusCompletion)completion;

/**
 * Deletes image specified by an ID.
 *
 * @param inputID     id of image you want to delete.
 * @param completion  Invoked when the request completes.
 */
- (void)deleteInput:(NSString *)inputID completion:(ClarifaiRequestCompletion)completion;

/**
 * Deletes images specified by an array of ClarifaiInputs. Note that each Clarifai input
 * must contain an inputID at the very least, that matches the input you would like to delete.
 *
 * @param inputs      Array of ClarifaiInputs containing id's of the inputs you want to delete.
 * @param completion  Invoked when the request completes.
 */
- (void)deleteInputsByIDList:(NSArray <ClarifaiInput *> *)inputs completion:(ClarifaiRequestCompletion)completion;

/**
 * Deletes all inputs associated with you app.
 *
 * @param completion  Invoked when the request completes.
 */
- (void)deleteAllInputs:(ClarifaiRequestCompletion)completion;

/**
 * Retrieves concepts that have been saved to your Clarifai application on the specified page.
 *
 * @param page         The page of concepts that you want to list.
 * @param pageSize     The size that you'd like pages to be.
 * @param completion   Invoked when the request completes.
 */
- (void)getConceptsOnPage:(int)page pageSize:(int)pageSize
              completion:(ClarifaiSearchConceptCompletion)completion;

/**
 * Retrieves a single concept that has been saved by your Clarifai application.
 *
 * @param conceptID    String containing the id of the concept you'd like to retrieve.
 * @param completion   Invoked when the request completes.
 */
- (void)getConcept:(NSString *)conceptID
        completion:(ClarifaiStoreConceptCompletion)completion;

/**
 * Saves concepts to your Clarifai application.
 *
 * @param concepts     Array containing ClarifaiConcepts to save. You must populate this
 *                     array and at least set id's for each concept. You can also add
 *                     a name, which does not need to be unique. To create a
 *                     concept, see ClarifaiConcept.
 * @param completion   Invoked when the request completes.
 */
- (void)addConcepts:(NSArray <ClarifaiConcept *> *)concepts completion:(ClarifaiSearchConceptCompletion)completion;


/**
 * This can be used to add tags to an existing model.
 *
 * @param concepts      Array of new ClarifaiConcepts.
 * @param inputID       String containing the id of the model you'd like to update
 *                      concepts for.
 * @param completion    Invoked when the update completes.
 */
- (void)addConcepts:(NSArray <ClarifaiConcept *> *)concepts toModelWithID:(NSString *)modelID completion:(ClarifaiModelCompletion)completion;

/**
 * This can be used to remove tags from an existing model.
 *
 * @param concepts      Array of ClarifaiConcepts.
 * @param inputID       String containing the id of the model you'd like to update
 *                      concepts for.
 * @param completion    Invoked when the update completes.
 */
- (void)deleteConcepts:(NSArray <ClarifaiConcept *> *)concepts fromModelWithID:(NSString *)modelID completion:(ClarifaiModelCompletion)completion;

#pragma mark - Search

/**
 * Search using tags and/or visual similarity.
 *
 * @param tags            An array of arrays that are anded together to create the query. Each tag in the sub-arrays is or'd togther.
 * @param page            The page number of results to show.
 * @param perPage  Number of results per page.
 * @param completion      Invoked when the request completes.
 */
- (void)search:(NSArray <ClarifaiSearchTerm *> *)searchTerms
          page:(NSNumber *)page
       perPage:(NSNumber *)perPage
    completion:(ClarifaiSearchCompletion)completion;


#pragma mark - Models

/**
 * Get  models in your application.
 *
 * @param page            Results page to load.
 * @param resultsPerPage  Number of results per page.
 * @param completion      Invoked when the request completes.
 */
- (void)getModels:(int)page resultsPerPage:(int)resultsPerPage completion:(ClarifaiModelsCompletion)completion;

/**
 * Retrieve a specific model by ID.
 *
 * @param modelID         ID of the model to find.
 * @param completion      Invoked when the request completes.
 */
- (void)getModelByID:(NSString *)modelID completion:(ClarifaiModelCompletion)completion;

/**
 * Retrieve a specific model by name.
 *
 * @param modelName       Name of the model to find.
 * @param completion      Invoked when the request completes.
 */
- (void)getModelByName:(NSString *)modelName completion:(ClarifaiModelCompletion)completion;

/**
 * List versions of a given model.
 *
 * @param modelID         ID of model to find different versions of.
 * @param page            Results page to load.
 * @param resultsPerPage  Number of results to return per page.
 * @param completion      Invoked when the request completes.
 */
- (void)listVersionsForModel:(NSString *)modelID
                        page:(int)page
              resultsPerPage:(int)resultsPerPage
                  completion:(ClarifaiModelVersionsCompletion)completion;

/**
 * Get specific version of a given model.
 *
 * @param modelID         ID of model to find different versions of.
 * @param versionID       ID of the version info you want to retrieve.
 * @param completion      Invoked when the request completes.
 */
- (void)getVersionForModel:(NSString *)modelID
                 versionID:(NSString *)versionID
                completion:(ClarifaiModelVersionCompletion)completion;

/**
 * Delete specific version of a given model.
 *
 * @param model           ID of model to find different versions of.
 * @param versionID       ID of the version info you want to retrieve.
 * @param completion      Invoked when the request completes.
 */
- (void)deleteVersionForModel:(NSString *)modelID
                    versionID:(NSString *)versionID
                   completion:(ClarifaiRequestCompletion)completion;

/**
 * Get training inputs associated with a given model.
 *
 * @param modelID         ID of model to find different versions of.
 * @param page            Results page to load.
 * @param resultsPerPage  Number of results to return per page.
 * @param completion      Invoked when the request completes.
 */
- (void)listTrainingInputsForModel:(NSString *)modelID
                              page:(int)page
                    resultsPerPage:(int)resultsPerPage
                        completion:(ClarifaiInputsCompletion)completion;

/**
 * Get training inputs associated with a given model and version.
 *
 * @param modelID           ID of model to find version of.
 * @param versionID       ID of the version you want to retrieve.
 * @param page            Results page to load.
 * @param resultsPerPage  Number of results to return per page.
 * @param completion      Invoked when the request completes.
 */
- (void)listTrainingInputsForModel:(NSString *)modelID
                           version:(NSString *)versionID
                              page:(int)page
                    resultsPerPage:(int)resultsPerPage
                        completion:(ClarifaiInputsCompletion)completion;

/**
 * Search for model by name.
 *
 * @param modelName       Name of the model you'd like to search for.
 * @param modelType       Type of model you'd like to search for. {embed, concept, cluster, detection, color}
 * @param completion      Invoked when the request completes.
 */
- (void)searchForModelByName:(NSString *)modelName
                   modelType:(ClarifaiModelType)modelType
                  completion:(ClarifaiModelsCompletion)completion;

/**
 * Create a model.
 *
 * @param concepts                      Concepts that belong to the new model. These MUST be concepts that already 
 *                                      have been added within the app, either directly or to inputs. This will 
 *                                      not create new concepts for conceptIDs that the app doesn't contain already.
 *                                      You can pass in ClarifaiConcepts or NSStrings. If you pass strings, concepts
 *                                      this method will create a model with concepts named with the given strings.
 * @param name                          Name of the model.
 * @param conceptsMutuallyExclusive     Do you expect to see more than one of the concepts in this 
 *                                      model in the SAME image? If Yes, then 
 *                                      conceptsMutuallyExclusive: false (default), if No, then 
 *                                      conceptsMutuallyExclusive: true.
 * @param closedEnvironment             Do you expect to run the trained model on images that do not
 *                                      contain ANY of the concepts in the model? If yes, 
 *                                      closedEnvironment: false (default), if no closedEnvironment:
 *                                      true.
 *                                      as negative examples for concepts in the model.
 * @param completion                    Invoked when the request completes.
 */
- (void)createModel:(NSArray <ClarifaiConcept *> *)concepts
                     name:(NSString *)modelName
conceptsMutuallyExclusive:(BOOL)conceptsMutuallyExclusive
        closedEnvironment:(BOOL)closedEnvironment
               completion:(ClarifaiModelCompletion)completion;

/**
 * Deletes model specified by an ID.
 *
 * @param modelID     id of model you want to delete.
 * @param completion  Invoked when the request completes.
 */
- (void)deleteModel:(NSString *)modelID completion:(ClarifaiRequestCompletion)completion;

/**
 * Deletes all models associated with your app.
 *
 * @param completion  Invoked when the request completes.
 */
- (void)deleteAllModels:(ClarifaiRequestCompletion)completion;

/**
 * Returns a ClarifaiModel with the requested ID, containing the outputinfo for the model. The outputinfo contains info like which concepts are associated with the model, the 
 * model's output type, etc.
 *
 * @param modelID     id of the model.
 * @param completion  Invoked when the request completes.
 */
- (void)getOutputInfoForModel:(NSString *)modelID completion:(ClarifaiModelCompletion)completion;

- (void)ensureValidAccessToken:(void (^)(NSError *error))handler;

@end
