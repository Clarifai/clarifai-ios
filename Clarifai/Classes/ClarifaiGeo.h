//
//  ClarifaiGeo.h
//  Pods
//
//  Created by John Sloan on 2/15/17.
//
//

#import <Foundation/Foundation.h>
#import "ClarifaiLocation.h"

typedef NS_ENUM(NSInteger, ClarifaiRadiusUnit) {
  ClarifaiRadiusUnitMiles,
  ClarifaiRadiusUnitKilometers,
  ClarifaiRadiusUnitDegrees,
  ClarifaiRadiusUnitRadians
};

@interface ClarifaiGeoBox : NSObject

@property (strong, nonatomic) ClarifaiLocation *startLoc;
@property (strong, nonatomic) ClarifaiLocation *endLoc;

@end

@interface ClarifaiGeo : NSObject

@property (strong, nonatomic) ClarifaiGeoBox *geoBox;
@property (strong, nonatomic) ClarifaiLocation *geoPoint;
@property (strong, nonatomic) NSNumber *radius;
@property (strong, nonatomic) NSString *unitType;

- (instancetype)initWithLocation:(ClarifaiLocation *)location andRadius:(double)radius;
- (instancetype)initWithLocation:(ClarifaiLocation *)location radius:(double)radius andRadiusUnit:(ClarifaiRadiusUnit)unit;
- (instancetype)initWithGeoBoxFromStartLocation:(ClarifaiLocation *)startLocation toEndLocation:(ClarifaiLocation *)endLocation;
- (void)setRadiusUnit:(ClarifaiRadiusUnit)unit;
- (NSDictionary *) geoFilterAsDictionary;

@end
