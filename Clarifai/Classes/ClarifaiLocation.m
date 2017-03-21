//
//  ClarifaiLocation.m
//  Pods
//
//  Created by John Sloan on 2/3/17.
//
//

#import "ClarifaiLocation.h"

@implementation ClarifaiLocation

- (instancetype)initWithLatitude:(double)latitude longitude:(double)longitude {
  self = [super init];
  if (self) {
    _latitude = latitude;
    _longitude = longitude;
  }
  return self;
}

- (CLLocation *)clLocation {
  return [[CLLocation alloc] initWithLatitude:_latitude longitude:_longitude];
}

@end
