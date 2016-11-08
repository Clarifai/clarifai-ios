//
//  ClarifaiApp.h
//  ClarifaiApiDemo
//
//  Created by John Sloan on 9/1/16.
//  Copyright © 2016 Clarifai, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import "ClarifaiModel.h"
#import "ClarifaiSearchTerm.h"
#import "ClarifaiConcept.h"
#import "ClarifaiImage.h"
#import "ClarifaiInput.h"
#import "ClarifaiOutput.h"
#import "ClarifaiConstants.h"

/**
 * API calls are tied to an account and application. Any model you create or inputs you add, will be contained within an application. After creating an app on the [Clarifai developer page](https://developer.clarifai.com/applications) you can use your app's id and secret to create a ClarifaiApp object. A ClarifaiApp instance will be the main hub of interfacing with an application. It is used to create, get, update, and search the various components of your application including: inputs, concepts, and models.
 */
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
 * @param inputs       Array containing ClarifaiInputs to save to your application.
 * @param completion   Invoked when the request completes.
 */
- (void)addInputs:(NSArray <ClarifaiInput *> *)inputs completion:(ClarifaiInputsCompletion)completion;

/**
 * Merge tags to an existing input.
 *
 * @warning             Merging will overwrite values for tags with matching id's, or append to the
 *                      input's existing list of tags in the app.
 *
 * @param concepts      Array of new or updated ClarifaiConcepts to merge.
 * @param inputID       String containing the id of the input you'd like to merge concepts to.
 * @param completion    Invoked when the update completes.
 */
- (void)mergeConcepts:(NSArray <ClarifaiConcept *> *)concepts forInputWithID:(NSString *)inputID completion:(ClarifaiStoreInputCompletion)completion;

/**
 * Merge tags to one or more existing inputs.
 *
 * @warning             Merging will overwrite values for tags with matching id's, or append to an
 *                      input's existing list of tags in the app.
 *
 * @param inputs        Array of ClarifaiInputs to merge tags to. Each input should contain the 
 *                      list of tags to be merged in it's concepts array property. Each input
 *                      must also have an inputID.
 * @param completion    Invoked when the update completes.
 */
- (void)mergeConceptsForInputs:(NSArray<ClarifaiInput *> *)inputs completion:(ClarifaiInputsCompletion)completion;

/**
 * Overwrites tags of existing input with given ID.
 *
 * @warning             This method will overwrite values for tags with matching id's, or overwrite the
 *                      input's list of tags with the new list of tags.
 *
 * @param inputID       String containing the id of the input you'd like to overwrite concepts for.
 * @param completion    Invoked when the update completes.
 */
- (void)setConcepts:(NSArray <ClarifaiConcept *> *)concepts forInputWithID:(NSString *)inputID completion:(ClarifaiStoreInputCompletion)completion;

/**
 * Overwrites tags of one or more existing inputs.
 *
 * @warning             This method will overwrite values for tags with matching id's, or overwrite each 
 *                      input's list of tags with the new list of tags.
 *
 * @param inputs        Array of ClarifaiInputs to add tags to. Each input should contain
 *                      the tags to be added in it's concepts array property. Each input must also 
 *                      have an inputID.
 * @param completion    Invoked when the update completes.
 */
- (void)setConceptsForInputs:(NSArray<ClarifaiInput *> *)inputs completion:(ClarifaiInputsCompletion)completion;

/**
 * Delete tags from an existing input.
 *
 * @param concepts      Array of ClarifaiConcepts to delete. These must have matching conceptID's
 *                      to whichever ones are being deleted.
 * @param inputID       String containing the id of the input you'd like to delete
 *                      concepts from.
 * @param completion    Invoked when the update completes.
 */
- (void)deleteConcepts:(NSArray <ClarifaiConcept *> *)concepts forInputWithID:(NSString *)inputID completion:(ClarifaiStoreInputCompletion)completion;

/**
 * Delete tags from one or more existing inputs.
 *
 * @param inputs        Array of ClarifaiInputs to delete tags from. Each input should contain
 *                      a list of tags to be deleted as it's concepts array property. Each input must
 *                      also have an inputID.
 * @param completion    Invoked when the update completes.
 */
- (void)deleteConceptsForInputs:(NSArray<ClarifaiInput *> *)inputs completion:(ClarifaiInputsCompletion)completion;

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
- (void)getInput:(NSString *)inputID completion:(ClarifaiStoreInputCompletion)completion;

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
 * Deletes images specified by either an array of ClarifaiInputs or inputID NSStrings. Note that each
 * ClarifaiInput must contain an inputID at the very least, that matches the input you would like to delete. 
 * 
 * @warning This method is async on the server, meaning that the request returns immediately,
 * before inputs have finished being deleted. To check for completion, use getInput: above. 
 * If one input in the list is gone, all have been deleted.
 *
 * @param inputs      Array of ClarifaiInputs containing id's of the inputs you want to delete.
 * @param completion  Invoked when the request completes.
 */
- (void)deleteInputsByIDList:(NSArray *)inputs completion:(ClarifaiRequestCompletion)completion;

/**
 * Deletes all inputs associated with you app.
 *
 * @warning This method is async on the server, meaning that the request returns immediately,
 * before inputs have finished being deleted. To check for completion, use getInput: above.
 * If one input in the list is gone, all have been deleted.
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
 * Merge a list of tags to an existing model.
 *
 * @warning             Merging will overwrite values for tags with matching id's, or append to the
 *                      model's existing list of tags in the app.
 *
 * @param concepts      Array of new ClarifaiConcepts.
 * @param modelID       String containing the id of the model you'd like to update
 *                      concepts for.
 * @param completion    Invoked when the update completes.
 */
- (void)mergeConcepts:(NSArray <ClarifaiConcept *> *)concepts forModelWithID:(NSString *)modelID completion:(ClarifaiModelCompletion)completion;

/**
 * Overwrite the list of tags of an existing model with a new list of tags.
 *
 * @param concepts      Array of new ClarifaiConcepts.
 * @param modelID       String containing the id of the model you'd like to update
 *                      concepts for.
 * @param completion    Invoked when the update completes.
 */
- (void)setConcepts:(NSArray <ClarifaiConcept *> *)concepts forModelWithID:(NSString *)modelID completion:(ClarifaiModelCompletion)completion;

/**
 * Remove tags from an existing model.
 *
 * @param concepts      Array of ClarifaiConcepts with id's matching the tags to be removed.
 * @param modelID       String containing the id of the model you'd like to update
 *                      concepts for.
 * @param completion    Invoked when the update completes.
 */
- (void)deleteConcepts:(NSArray <ClarifaiConcept *> *)concepts fromModelWithID:(NSString *)modelID completion:(ClarifaiModelCompletion)completion;

#pragma mark - Search

/**
 * Search using tags and/or visual similarity.
 *
 * @param searchTerms     An array of ClarifaiSearchTerms that are and-ed together to create the query.
 * @param page            The page number of results to show.
 * @param perPage         Number of results per page.
 * @param completion      Invoked when the request completes.
 */
- (void)search:(NSArray <ClarifaiSearchTerm *> *)searchTerms
          page:(NSNumber *)page
       perPage:(NSNumber *)perPage
    completion:(ClarifaiSearchCompletion)completion;

/**
 * Search using metadata previously added to the inputs in your application.
 *
 * @param metadata        Metadata to search inputs for. This can be any valid json object.
 * @param page            The page number of results to show.
 * @param perPage         Number of results per page.
 * @param isInput         Bool that indicates searching across inputs (true) or outputs (false).
 * @param completion      Invoked when the request completes.
 */
- (void)searchByMetadata:(NSDictionary *)metadata
                    page:(NSNumber *)page
                 perPage:(NSNumber *)perPage
                 isInput:(BOOL)isInput
              completion:(ClarifaiSearchCompletion)completion;

#pragma mark - Models

/**
 * Get models in your application.
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
 * Search for matching model names and retrieve the first one found.
 *
 * @warning This method only searches for models of type ClarifaiModelTypeConcept. 
 * To search for a model by name and type, such as Clarifai's color model, use 
 * searchForModelByName:modelType:
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
 * @param modelID         ID of model to find different versions of.
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
 * @param modelID         ID of model to find version of.
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
 * Search for model by name and type. 
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
 * @param concepts    Concepts that belong to the new model. These MUST be concepts
 * that already have been added within the app, either directly or to inputs. 
 * This will not create new concepts for conceptIDs that the app doesn't
 * contain already. You can pass in ClarifaiConcepts or NSStrings. If you 
 * pass strings this method will create a model with concepts named
 * with the given strings.
 *
 * @param modelName    Name of the model. This will automatically use the name as the ModelID as well.
 *
 * @param conceptsMutuallyExclusive    Do you expect to see more than one of 
 * the concepts in this model in the SAME image? If Yes, then 
 * conceptsMutuallyExclusive: false (default), if No, then conceptsMutuallyExclusive: true.
 *
 * @param closedEnvironment    Do you expect to run the trained model on images that do not
 * contain ANY of the concepts in the model? If yes, closedEnvironment: false (default),
 * if no closedEnvironment: true.
 *
 * @param completion    Invoked when the request completes.
 */
- (void)createModel:(NSArray *)concepts
               name:(NSString *)modelName
conceptsMutuallyExclusive:(BOOL)conceptsMutuallyExclusive
  closedEnvironment:(BOOL)closedEnvironment
         completion:(ClarifaiModelCompletion)completion;

/**
 * Create a model.
 *
 * @param concepts    Concepts that belong to the new model. These MUST be concepts
 * that already have been added within the app, either directly or to inputs.
 * This will not create new concepts for conceptIDs that the app doesn't
 * contain already. You can pass in ClarifaiConcepts or NSStrings. If you
 * pass strings this method will create a model with concepts named
 * with the given strings.
 *
 * @param modelName    Name of the model. This will automatically use the name as the ModelID as well.
 *
 * @param modelName    ID of the model. ID's MUST be unique for each model.
 *
 * @param conceptsMutuallyExclusive    Do you expect to see more than one of
 * the concepts in this model in the SAME image? If Yes, then
 * conceptsMutuallyExclusive: false (default), if No, then conceptsMutuallyExclusive: true.
 *
 * @param closedEnvironment    Do you expect to run the trained model on images that do not
 * contain ANY of the concepts in the model? If yes, closedEnvironment: false (default),
 * if no closedEnvironment: true.
 *
 * @param completion    Invoked when the request completes.
 */
- (void)createModel:(NSArray *)concepts
               name:(NSString *)modelName
            modelID:(NSString *)modelID
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
 * @warning This method is async on the server, meaning that the request returns immediately,
 * before models have finished being deleted. To check for completion, use getModelByID: above.
 * If one model in the list is gone, all have been deleted.
 *
 * @param completion  Invoked when the request completes.
 */
- (void)deleteAllModels:(ClarifaiRequestCompletion)completion;

/**
 * Deletes models specified by either an array of ClarifaiModels or modelID NSStrings. Note that each
 * ClarifaiModel must contain a modelID at the very least, that matches the model you would like to delete.
 *
 * @warning This method is async on the server, meaning that the request returns immediately,
 * before models have finished being deleted. To check for completion, use getModelByID: above.
 * If one model in the list is gone, all have been deleted.
 *
 * @param models      Array of ClarifaiModels containing id's of the models you want to delete.
 * @param completion  Invoked when the request completes.
 */
- (void)deleteModelsByIDList:(NSArray *)models completion:(ClarifaiRequestCompletion)completion;

/**
 * Returns a ClarifaiModel with the requested ID, containing the outputinfo for the model. The outputinfo contains info like which concepts are associated with the model, the model's output type, etc.
 *
 * @param modelID     id of the model.
 * @param completion  Invoked when the request completes.
 */
- (void)getOutputInfoForModel:(NSString *)modelID completion:(ClarifaiModelCompletion)completion;

- (void)ensureValidAccessToken:(void (^)(NSError *error))handler;

@end
