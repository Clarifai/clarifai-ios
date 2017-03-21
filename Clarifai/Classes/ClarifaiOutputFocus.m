//
//  ClarifaiOutputFocus.m
//  Pods
//
//  Created by John Sloan on 3/17/17.
//
//

#import "ClarifaiOutputFocus.h"

@implementation ClarifaiOutputFocus

- (instancetype)initWithDictionary:(NSDictionary *)dict {
  self = [super initWithDictionary:dict];
  if (self) {
    // check that data dictionary exists.
    if (![dict[@"data"] isKindOfClass: [NSNull class]]) {
      // add focus value to output, if present.
      if (![dict[@"data"][@"focus"] isKindOfClass: [NSNull class]]) {
        _focusDensity = [[dict[@"data"][@"focus"] valueForKey:@"value"] doubleValue];
      }
      
      // add focus regions to output, if any.
      NSArray *facesArray = dict[@"data"][@"regions"];
      NSMutableArray *focusRegions = [NSMutableArray array];
      for (NSDictionary *faceData in facesArray) {
        ClarifaiOutputRegion *region = [[ClarifaiOutputRegion alloc] initWithDictionary:faceData];
        [focusRegions addObject:region];
      }
      self.focusRegions = focusRegions;
    }
  }
  return self;
}

@end
