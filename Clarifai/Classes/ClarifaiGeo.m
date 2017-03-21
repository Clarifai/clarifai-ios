//
//  ClarifaiGeo.m
//  Pods
//
//  Created by John Sloan on 2/15/17.
//
//

#import "ClarifaiGeo.h"

@implementation ClarifaiGeoBox
// Initialize a geo box defined as a rectangular area between two locations as opposing corners.
- (instancetype)initWithStartLocation:(ClarifaiLocation *)startLocation endLocation:(ClarifaiLocation *)endLocation {
  self = [super init];
  if (self) {
    _startLoc = startLocation;
    _endLoc = endLocation;
  }
  return self;
}
@end


@implementation ClarifaiGeo

- (instancetype)initWithLocation:(ClarifaiLocation *)location andRadius:(double)radius {
  self = [super init];
  if (self) {
    _geoPoint = location;
    _radius = [NSNumber numberWithDouble:radius];
    _unitType = @"withinMiles";
  }
  return self;
}

- (instancetype)initWithLocation:(ClarifaiLocation *)location radius:(double)radius andRadiusUnit:(ClarifaiRadiusUnit)unit {
  self = [super init];
  if (self) {
    _geoPoint = location;
    _radius = [NSNumber numberWithDouble:radius];
    [self setRadiusUnit:unit];
  }
  return self;
}

- (instancetype)initWithGeoBoxFromStartLocation:(ClarifaiLocation *)startLocation toEndLocation:(ClarifaiLocation *)endLocation {
  self = [super init];
  if (self) {
    _geoBox = [[ClarifaiGeoBox alloc] initWithStartLocation:startLocation endLocation:endLocation];
    _unitType = @"withinMiles";
  }
  return self;
}

- (void)setRadiusUnit:(ClarifaiRadiusUnit)unit {
  switch (unit) {
    case ClarifaiRadiusUnitMiles:
      _unitType = @"withinMiles";
      break;
    
    case ClarifaiRadiusUnitKilometers:
      _unitType = @"withinKilometers";
      break;
      
    case ClarifaiRadiusUnitDegrees:
      _unitType = @"withinDegrees";
      break;
      
    case ClarifaiRadiusUnitRadians:
      _unitType = @"withinRadians";
      break;
      
    default:
      _unitType = @"withinMiles";
      break;
  }
}

- (NSDictionary *) geoFilterAsDictionary {
  NSMutableDictionary *geoDict = [NSMutableDictionary dictionary];
  if (_geoBox) {
    geoDict[@"geo_box"] = @[@{@"geo_point":
                              @{@"latitude":[NSNumber numberWithDouble:_geoBox.startLoc.latitude],
                                @"longitude":[NSNumber numberWithDouble:_geoBox.startLoc.longitude]}
                            },
                            @{@"geo_point":
                                @{@"latitude":[NSNumber numberWithDouble:_geoBox.endLoc.latitude],
                                  @"longitude":[NSNumber numberWithDouble:_geoBox.endLoc.longitude]}
                              }
                            ];
  } else if (_geoPoint && _radius && _unitType) {
    geoDict[@"geo_point"] = @{@"latitude":[NSNumber numberWithDouble:_geoPoint.latitude],
                              @"longitude":[NSNumber numberWithDouble:_geoPoint.longitude]};
    
    geoDict[@"geo_limit"] = @{@"type":_unitType,
                              @"value":_radius
                              };
  }
  
  return geoDict;
}

@end
