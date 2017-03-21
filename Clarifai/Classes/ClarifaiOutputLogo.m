//
//  ClarifaiOutputLogo.m
//  Pods
//
//  Created by John Sloan on 3/21/17.
//
//

#import "ClarifaiOutputLogo.h"

@implementation ClarifaiOutputLogo

- (instancetype)initWithDictionary:(NSDictionary *)dict {
  self = [super initWithDictionary:dict];
  if (self) {
    // check that data dictionary exists.
    if (![dict[@"data"] isKindOfClass: [NSNull class]]){
      // add logos to output, if any.
      NSArray *logosArray = dict[@"data"][@"regions"];
      NSMutableArray *logos = [NSMutableArray array];
      for (NSDictionary *logoData in logosArray) {
        ClarifaiOutputRegion *region = [[ClarifaiOutputRegion alloc] initWithDictionary:logoData];
        [logos addObject:region];
      }
      self.logos = logos;
    }
  }
  return self;
}

@end
