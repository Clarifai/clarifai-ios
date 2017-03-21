//
//  ClarifaiOutputRegion.m
//  Pods
//
//  Created by John Sloan on 3/20/17.
//
//

#import "ClarifaiOutputRegion.h"

@implementation ClarifaiOutputRegion

- (instancetype)initWithDictionary:(NSDictionary *)dict {
  self = [super init];
  if (self) {
    if (![dict[@"region_info"] isKindOfClass:[NSNull class]] && ![dict[@"region_info"][@"bounding_box"] isKindOfClass:[NSNull class]]) {
      // Add bounding box if present for current region.
      NSDictionary *regionBox = dict[@"region_info"][@"bounding_box"];
      _top = [[regionBox valueForKey:@"top_row"] doubleValue];
      _left = [[regionBox valueForKey:@"left_col"] doubleValue];
      _bottom = [[regionBox valueForKey:@"bottom_row"] doubleValue];
      _right = [[regionBox valueForKey:@"right_col"] doubleValue];
      
      // Add focus value, if present for current region.
      if (![dict[@"region_info"][@"focus"] isKindOfClass:[NSNull class]]) {
        _focusDensity = [[dict[@"region_info"][@"focus"] valueForKey:@"density"] doubleValue];
      }
    }
    
    if (![dict[@"data"] isKindOfClass:[NSNull class]]) {
      // Add concepts, if present for current region.
      NSMutableArray <ClarifaiConcept *> *concepts = [NSMutableArray array];
      NSArray *conceptsArray = dict[@"data"][@"concepts"];
      for (NSDictionary *conceptDict in conceptsArray) {
        ClarifaiConcept *concept = [[ClarifaiConcept alloc] initWithDictionary:conceptDict];
        [concepts addObject:concept];
      }
      _concepts = concepts;
    }    
  }
  return self;
}

@end
