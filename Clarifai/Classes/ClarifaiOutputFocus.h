//
//  ClarifaiOutputFocus.h
//  Pods
//
//  Created by John Sloan on 3/17/17.
//
//

#import "ClarifaiOutput.h"
#import "ClarifaiOutputRegion.h"

@interface ClarifaiOutputFocus : ClarifaiOutput

/** The greatest focus density detected. */
@property (nonatomic) double focusDensity;

/** The bounding boxes of all focus regions detected. */
@property (strong,nonatomic) NSArray<ClarifaiOutputRegion *> *focusRegions;
  
- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end
