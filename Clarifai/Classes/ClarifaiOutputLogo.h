//
//  ClarifaiOutputLogo.h
//  Pods
//
//  Created by John Sloan on 3/21/17.
//
//

#import "ClarifaiOutput.h"
#import "ClarifaiOutputRegion.h"

@interface ClarifaiOutputLogo : ClarifaiOutput

/** The bounding boxes of all logos detected. */
@property (strong,nonatomic) NSArray<ClarifaiOutputRegion *> *logos;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end
