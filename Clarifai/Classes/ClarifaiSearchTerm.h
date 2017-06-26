//
//  ClarifaiSearchTerm.h
//  Pods
//
//  Created by John Sloan on 3/7/17.
//
//

#import <Foundation/Foundation.h>
#import "ClarifaiConcept.h"
#import "ClarifaiGeo.h"
#import "ClarifaiCrop.h"

@interface ClarifaiSearchTerm : NSObject

#pragma mark Search outputs

/**
 * Creates a search term from an imageURL. This will visually search the inputs
 * of your application for all inputs that look similar to the given imageURL.
 *
 * @param imageURL  The url of an image to be visually searched.
 */
+ (ClarifaiSearchTerm *) searchVisuallyWithImageURL:(NSString *)imageURL;

/**
 * Creates a search term from an imageURL and crop. This will first crop the image
 * located at the given URL and then visually search the inputs of your application
 * for all inputs that look similar to the cropped image.
 *
 * @param imageURL   The url of an image to be visually searched.
 * @param imageCrop  Specifies a crop for the image, prior to searching.
 */
+ (ClarifaiSearchTerm *) searchVisuallyWithImageURL:(NSString *)imageURL andCrop:(ClarifaiCrop *)imageCrop;

/**
 * Creates a search term from an inputID. This will visually search the inputs
 * of your application for all inputs that look similar to the image of the given inputID.
 *
 * @param inputID    The inputID of the input to be visually searched.
 */
+ (ClarifaiSearchTerm *) searchVisuallyWithInputID:(NSString *)inputID;

/**
 * Creates a search term from image data. This will visually search the inputs
 * of your application for all inputs that look similar to the image of the given data.
 *
 * @param imageData  The NSData of an image to be visually searched.
 */
+ (ClarifaiSearchTerm *) searchVisuallyWithImageData:(NSData *)imageData;

/**
 * Creates a search term from a UIImage. This will visually search the inputs
 * of your application for all inputs that look similar to the given UIImage.
 *
 * @param image      A UIImage to be visually searched.
 */
+ (ClarifaiSearchTerm *) searchVisuallyWithUIImage:(UIImage *)image;

/**
 * Creates a search term from a ClarifaiConcept. This will search the inputs of your 
 * application by predicting which inputs are associated with the given concept.
 *
 * @warning        Concepts can only be searched if they are either in Clarifai's
 *                 general model, or part of a TRAINED custom model. To find out
 *                 which tags are available to use in a search term (or for autocomplete
 *                 purposes), you can use [app searchForConceptsByName:andLanguage:completion:].
 *                 See ClarifaiApp for more details on this.
 *
 * @param concept  The NSData of an image to be visually searched.
 */
+ (ClarifaiSearchTerm *) searchByPredictedConcept:(ClarifaiConcept *)concept;

/**
 * Adds an image crop to the current visual search term.
 *
 * @warning          A crop can only be added to images for visual search. This method
 *                   will do nothing if the search term is created for other types of searches.
 *
 *
 * @param imageCrop  An image crop that will crop the input image before searching.
 */
- (ClarifaiSearchTerm *)addImageCrop:(ClarifaiCrop *)imageCrop;

#pragma mark Search inputs

/**
 * Creates a search term from an imageURL. This will search the inputs of your
 * application for all inputs that contain the exact given URL.
 *
 * @param imageURL  The url to be searched.
 */
+ (ClarifaiSearchTerm *)searchInputsWithImageURL:(NSString *)imageURL;

/**
 * Creates a search term from an inputID. This will search the inputs of your
 * application for the input with a matching inputID.
 *
 * @param inputID   The inputID to be searched.
 */
+ (ClarifaiSearchTerm *)searchInputsWithInputID:(NSString *)inputID;

/**
 * Creates a search term from a geo filter. This will search the inputs of your 
 * application for all inputs with tagged locations within the range of the geo
 * filter. See ClarifaiGeo for more details on creating a geo filter.
 *
 * @param geo       A geo filter to search inputs.
 */
+ (ClarifaiSearchTerm *)searchInputsWithGeoFilter:(ClarifaiGeo *)geo;

/**
 * Creates a search term from a metadata dictionary. This will search the inputs
 * of your application for all inputs with matching metadata.
 *
 * @param metadata  An NSDictionary of metadata to be searched.
 */
+ (ClarifaiSearchTerm *)searchInputsWithMetadata:(NSDictionary *)metadata;

/**
 * Creates a search term from a ClarifaiConcept. This will search the inputs
 * of your application for all inputs explicitly tagged with the given concept.
 *
 * @warning         This method does not search using predicted concepts, this means
 *                  it will only search for inputs that were added explicitly with the
 *                  given custom concept. Use searchByPredictedConcept in order to search
 *                  for inputs by predicting which inputs are associated with the given
 *                  concept. Ex: searchByPredictedConcept is used for searching with
 *                  predicted concepts from Clarifai's general model or trained custom models.
 *
 * @param concept   A ClarifaiConcept to be searched.
 */
+ (ClarifaiSearchTerm *)searchInputsByConcept:(ClarifaiConcept *)concept;

/**
 * (Depracated) Create a search term from a search item. This can be a 
 * ClarifiaInput or ClarifaiConcept. Marking isInput:YES will search the 
 * inputs of your application, whereas isInput:NO will search predicted 
 * outputs of your application (like visual searching, and searching by 
 * predicted tags).
 * 
 * @param searchItem The item being searched. This can be an input or concept.
 * @param isInput A boolean value indicating wether the search term should be accross inputs or outputs.
 */
- (instancetype)initWithSearchItem:(id)searchItem isInput:(BOOL)isInput __attribute__((deprecated));

/**
 * Outputs the current search term as a dictionary formatted for sending to the Clarifai API as JSON.
 */
- (NSDictionary *)searchTermAsDictionary;

@end
