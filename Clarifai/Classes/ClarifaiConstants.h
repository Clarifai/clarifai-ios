//
//  ClarifaiCompletionBlocks.h
//  ClarifaiApiDemo
//
//  Created by John Sloan on 9/7/16.
//  Copyright © 2016 Clarifai, Inc. All rights reserved.
//

#import "ClarifaiSearchResult.h"

@class ClarifaiModel;
@class ClarifaiConcept;
@class ClarifaiInput;
@class ClarifaiImage;
@class ClarifaiOutput;
@class ClarifaiModelVersion;

#define SafeRunBlock(block, ...) block ? block(__VA_ARGS__) : nil

static NSString * const kApiBaseUrl = @"https://api.clarifai.com/v2";
static NSString * const kErrorDomain = @"com.clarifai.ClarifaiClient";
static NSString * const kKeyAccessToken = @"com.clarifai.ClarifaiClient.AccessToken";
static NSString * const kKeyAppID = @"com.clarifai.ClarifaiClient.AppID";
static NSString * const kKeyAccessTokenExpiration = @"com.clarifai.ClarifaiClient.AccessTokenExpiration";
static NSTimeInterval const kMinTokenLifetime = 60.0;

/**
 * @param error Error code or nil if no error occured. */
typedef void (^ClarifaiRequestCompletion)(NSError *error);

/**
 * @param inputs   An array containing ClarifaiInputs returned from the api.
 * @param error    Error code or nil if no error occured. */
typedef void (^ClarifaiInputsCompletion)(NSArray <ClarifaiInput *> *inputs, NSError *error);

/**
 * @param outputs  An array containing ClarifaiSearchResults returned from the api.
 * @param error    Error code or nil if no error occured. */
typedef void (^ClarifaiSearchCompletion)(NSArray <ClarifaiSearchResult *> *results, NSError *error);

/**
 * @param outputs  An array containing ClarifaiOutputs returned from the api.
 * @param error    Error code or nil if no error occured. */
typedef void (^ClarifaiPredictionsCompletion)(NSArray <ClarifaiOutput *> *outputs, NSError *error);

/**
 * @param concepts An array containing ClarifaiConcepts returned from the api.
 * @param error    Error code or nil if no error occured. */
typedef void (^ClarifaiConceptsCompletion)(NSArray <ClarifaiConcept *> *concepts, NSError *error);

/**
 * @param input    A ClarifaiInput returned from the api.
 * @param error    Error code or nil if no error occured. */
typedef void (^ClarifaiStoreInputCompletion)(ClarifaiInput *input, NSError *error);

/**
 * @param concept  A ClarifaiConcept returned from the api.
 * @param error    Error code or nil if no error occured. */
typedef void (^ClarifaiStoreConceptCompletion)(ClarifaiConcept *concept, NSError *error);

/**
 * @param numProcessed   Number of inputs processed so far in your application.
 * @param numToProcess   Number of inputs queued for processing in your application.
 * @param errors         Number of errors so far while processing inputs.
 * @param error          Error code or nil if no error occured. */
typedef void (^ClarifaiInputsStatusCompletion)(int numProcessed, int numToProcess, int errors, NSError *error);

/**
 * @param models   An array containing ClarifaiModels returned from the api.
 * @param error    Error code or nil if no error occured. */
typedef void (^ClarifaiModelsCompletion)(NSArray <ClarifaiModel *> *models, NSError *error);

/**
 * @param model    A ClarifaiModel returned from the api.
 * @param error    Error code or nil if no error occured. */
typedef void (^ClarifaiModelCompletion)(ClarifaiModel *model, NSError *error);

/**
 * @param versions An array of ClarifaiModelVersions returned from the api.
 * @param error    Error code or nil if no error occured. */
typedef void (^ClarifaiModelVersionsCompletion)(NSArray <ClarifaiModelVersion *> *versions, NSError *error);

/**
 * @param version  A ClarifaiModelVersion returned from the api.
 * @param error    Error code or nil if no error occured. */
typedef void (^ClarifaiModelVersionCompletion)(ClarifaiModelVersion *version, NSError *error);

/**
 * @param concepts An array containing ClarifaiConcepts returned from the api.
 * @param error    Error code or nil if no error occured. */
typedef void (^ClarifaiSearchConceptCompletion)(NSArray <ClarifaiConcept *> *concepts, NSError *error);
