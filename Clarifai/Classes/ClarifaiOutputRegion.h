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

/** Predictions for the current region of the image. This is only populated in some models, like Clarifai's Logo or Celeb model. */
@property (strong, nonatomic) NSArray <ClarifaiConcept *> *concepts;

/** If predicting with Clarifai's Blur model, this represents the density of the current focus region.  */
@property (nonatomic) double focusDensity;

/** Initializes an output region from the api response dictionary. */
- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end
