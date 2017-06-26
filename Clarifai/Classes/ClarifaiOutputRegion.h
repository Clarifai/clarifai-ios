//
//  ClarifaiOutputRegion.h
//  Pods
//
//  Created by John Sloan on 3/20/17.
//
//

#import <Foundation/Foundation.h>
#import "ClarifaiConcept.h"

@interface ClarifaiOutputRegion : NSObject

/** Defines the boudning box of the region. */
@property double top;
@property double left;
@property double bottom;
@property double right;

/** Predictions for the current region of the image. This is only populated in some models, like Clarifai's Logo model. */
@property (strong, nonatomic) NSArray<ClarifaiConcept *> *concepts;
  
/** If predicting with Clarifai's Blur model, this represents the density of the current focus region.  */
@property (nonatomic) double focusDensity;

/** If predicting with Clarifai's Demographics model, this represents a detected face's age appearance. */
@property (strong, nonatomic) NSArray<ClarifaiConcept *> *ageAppearance;
  
/** If predicting with Clarifai's Demographics model, this represents a detected face's gender appearance. */
@property (strong, nonatomic) NSArray<ClarifaiConcept *> *genderAppearance;

/** If predicting with Clarifai's Demographics model, this represents a detected face's multicultural appearance. */
@property (strong, nonatomic) NSArray<ClarifaiConcept *> *multiculturalAppearance;
  
/** If predicting with Clarifai's Celebrity model or similar, this represents a detected face's predicted identity. */
@property (strong, nonatomic) NSArray<ClarifaiConcept *> *identity;
  
/** Initializes an output region from the api response dictionary. */
- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end
