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
    if ([dict objectForKey:@"region_info"] != nil && [dict[@"region_info"] objectForKey:@"bounding_box"] != nil) {
      // Add bounding box if present for current region.
      NSDictionary *regionBox = dict[@"region_info"][@"bounding_box"];
      _top = [[regionBox valueForKey:@"top_row"] doubleValue];
      _left = [[regionBox valueForKey:@"left_col"] doubleValue];
      _bottom = [[regionBox valueForKey:@"bottom_row"] doubleValue];
      _right = [[regionBox valueForKey:@"right_col"] doubleValue];
      
      // Add focus value, if present for current region. TODO: This will be depracated soon.
      if ([dict[@"region_info"] objectForKey:@"focus"] != nil) {
        _focusDensity = [[dict[@"region_info"][@"focus"] valueForKey:@"density"] doubleValue];
      }
    }
    
    if ([dict objectForKey:@"data"] != nil) {
      NSDictionary *regionData = dict[@"data"];
      // Add focus value, if present for current region.
      if ([regionData objectForKey:@"focus"] != nil) {
        _focusDensity = [[regionData[@"focus"] valueForKey:@"density"] doubleValue];
      } else if ([regionData objectForKey:@"density"] != nil) {
        _focusDensity = [[regionData valueForKey:@"density"] doubleValue];
      }
      
      if ([regionData objectForKey:@"face"] != nil) {
        NSDictionary *faceData = regionData[@"face"];
        // Add face identity if present.
        if ([faceData objectForKey:@"identity"] != nil) {
          NSMutableArray <ClarifaiConcept *> *concepts = [NSMutableArray array];
          NSArray *conceptsArray = faceData[@"identity"][@"concepts"];
          for (NSDictionary *conceptDict in conceptsArray) {
            ClarifaiConcept *concept = [[ClarifaiConcept alloc] initWithDictionary:conceptDict];
            [concepts addObject:concept];
          }
          _identity = concepts;
        }
        
        // Add age demographics if present.
        if ([faceData objectForKey:@"age_appearance"] != nil) {
          NSMutableArray <ClarifaiConcept *> *concepts = [NSMutableArray array];
          NSArray *conceptsArray = faceData[@"age_appearance"][@"concepts"];
          for (NSDictionary *conceptDict in conceptsArray) {
            ClarifaiConcept *concept = [[ClarifaiConcept alloc] initWithDictionary:conceptDict];
            [concepts addObject:concept];
          }
          _ageAppearance = concepts;
        }
        
        // Add gender demographics if present.
        if ([faceData objectForKey:@"gender_appearance"] != nil) {
          NSMutableArray <ClarifaiConcept *> *concepts = [NSMutableArray array];
          NSArray *conceptsArray = faceData[@"gender_appearance"][@"concepts"];
          for (NSDictionary *conceptDict in conceptsArray) {
            ClarifaiConcept *concept = [[ClarifaiConcept alloc] initWithDictionary:conceptDict];
            [concepts addObject:concept];
          }
          _genderAppearance = concepts;
        }
        
        // Add multicultural demographics if present.
        if ([faceData objectForKey:@"multicultural_appearance"] != nil) {
          NSMutableArray <ClarifaiConcept *> *concepts = [NSMutableArray array];
          NSArray *conceptsArray = faceData[@"multicultural_appearance"][@"concepts"];
          for (NSDictionary *conceptDict in conceptsArray) {
            ClarifaiConcept *concept = [[ClarifaiConcept alloc] initWithDictionary:conceptDict];
            [concepts addObject:concept];
          }
          _multiculturalAppearance = concepts;
        }
        
      }
      // Add concepts, if present for current region.
      NSMutableArray <ClarifaiConcept *> *concepts = [NSMutableArray array];
      NSArray *conceptsArray = regionData[@"concepts"];
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
