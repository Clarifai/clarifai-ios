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
    // add focus value to output, if present.
    NSDictionary *focus = [dict findObjectForKey:@"focus"];
    if (![focus isKindOfClass: [NSNull class]]) {
      _focusDensity = [[focus findObjectForKey:@"value"] doubleValue];
    }
  }
  return self;
}

@end
