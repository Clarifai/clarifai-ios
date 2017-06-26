//
//  ClarifaiOutputRegion.m
//  Pods
//
//  Created by John Sloan on 3/20/17.
//
//

#import "ClarifaiOutputRegion.h"
#import "NSDictionary+Clarifai.h"

@implementation ClarifaiOutputRegion

- (instancetype)initWithDictionary:(NSDictionary *)dict {
  self = [super init];
  if (self) {
    // Add bounding box if present for current region.
    _top =  [[dict findObjectForKey:@"top_row"] doubleValue];
    _left = [[dict findObjectForKey:@"left_col"] doubleValue];
    _bottom = [[dict findObjectForKey:@"bottom_row"] doubleValue];
    _right = [[dict findObjectForKey:@"right_col"] doubleValue];
      
    // Add focus value, if present for current region.
    _focusDensity =[[dict findObjectForKey:@"density"] doubleValue];
    
    // Add face identity if present.
    NSMutableArray <ClarifaiConcept *> *identityConcepts = [NSMutableArray array];
    NSDictionary *identity = [dict findObjectForKey:@"identity"];
    NSArray *identityConceptsArray = [identity findObjectForKey:@"concepts"];
    for (NSDictionary *conceptDict in identityConceptsArray) {
      ClarifaiConcept *concept = [[ClarifaiConcept alloc] initWithDictionary:conceptDict];
      [identityConcepts addObject:concept];
    }
    _identity = identityConcepts;

    // Add age demographics if present.
    NSMutableArray <ClarifaiConcept *> *ageConcepts = [NSMutableArray array];
    NSDictionary *ageAppearance = [dict findObjectForKey:@"age_appearance"];
    NSArray *ageConceptsArray = [ageAppearance findObjectForKey:@"concepts"];
    for (NSDictionary *conceptDict in ageConceptsArray) {
      ClarifaiConcept *concept = [[ClarifaiConcept alloc] initWithDictionary:conceptDict];
      [ageConcepts addObject:concept];
    }
    _ageAppearance = ageConcepts;
    
    // Add gender demographics if present.
    NSMutableArray <ClarifaiConcept *> *genderConcepts = [NSMutableArray array];
    NSDictionary *genderAppearance = [dict findObjectForKey:@"gender_appearance"];
    NSArray *genderConceptsArray = [genderAppearance findObjectForKey:@"concepts"];
    for (NSDictionary *conceptDict in genderConceptsArray) {
      ClarifaiConcept *concept = [[ClarifaiConcept alloc] initWithDictionary:conceptDict];
      [genderConcepts addObject:concept];
    }
    _genderAppearance = genderConcepts;
    
    // Add multicultural demographics if present.
    NSMutableArray <ClarifaiConcept *> *multiculturalConcepts = [NSMutableArray array];
    NSDictionary *multiculturalAppearance = [dict findObjectForKey:@"multicultural_appearance"];
    NSArray *multiculturalConceptsArray = [multiculturalAppearance findObjectForKey:@"concepts"];
    for (NSDictionary *conceptDict in multiculturalConceptsArray) {
      ClarifaiConcept *concept = [[ClarifaiConcept alloc] initWithDictionary:conceptDict];
      [multiculturalConcepts addObject:concept];
    }
    _multiculturalAppearance = multiculturalConcepts;
    
    if ([dict objectForKey:@"data"] != nil) {
      NSDictionary *regionData = dict[@"data"];

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
