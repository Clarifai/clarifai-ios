//
//  ClarifaiLocation.h
//  Pods
//
//  Created by John Sloan on 2/3/17.
//
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface ClarifaiLocation : NSObject

/** The latitude of the location, in degrees. */
@property (nonatomic) double latitude;

/** The longitude of the location, in degrees. */
@property (nonatomic) double longitude;

/** Initialize a new location with latidude and longitude, in degrees. */
- (instancetype)initWithLatitude:(double)latitude longitude:(double)longitude;

/** Returns a CLLocation object from the location's latitude and longitude. */
- (CLLocation *)clLocation;

@end
