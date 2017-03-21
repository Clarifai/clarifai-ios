//
//  ClarifaiOutputFace.m
//  Pods
//
//  Created by John Sloan on 3/17/17.
//
//

#import "ClarifaiOutputFace.h"

@implementation ClarifaiOutputFace

- (instancetype)initWithDictionary:(NSDictionary *)dict {
  self = [super initWithDictionary:dict];
  if (self) {
    // check that data dictionary exists.
    if (![dict[@"data"] isKindOfClass: [NSNull class]]){
      // add faces to output, if any.
      NSArray *facesArray = dict[@"data"][@"regions"];
      NSMutableArray *faces = [NSMutableArray array];
      for (NSDictionary *faceData in facesArray) {
        ClarifaiOutputRegion *region = [[ClarifaiOutputRegion alloc] initWithDictionary:faceData];
        [faces addObject:region];
      }
      self.faces = faces;
    }
  }
  return self;
}

@end
