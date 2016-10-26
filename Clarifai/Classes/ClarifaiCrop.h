//
//  ClarifaiCrop.h
//  Pods
//
//  Created by John Sloan on 10/13/16.
//
//

#import <Foundation/Foundation.h>

/**
 * When adding an input, you can specify crop points. The API will
 * crop the image and use the resulting image. Crop points are given
 * as percentages from the top left point in the order of top, left, bottom and right.
 */
@interface ClarifaiCrop : NSObject

/** 
 * Specifies the top edge as a percentage of the original image (a float from 0-1).
 * With a value of 0.2 the cropped image will have a top edge that starts 20% down from the original top edge.
 */
@property (nonatomic) CGFloat top;

/**
 * Specifies the left edge as a percentage of the original image (a float from 0-1).
 * With a value of 0.4 the cropped image will have a left edge that starts 40% from the original left edge.
 */
@property (nonatomic) CGFloat left;

/**
 * Specifies the bottom edge as a percentage of the original image (a float from 0-1).
 * With a value of 0.3 the cropped image will have a bottom edge that starts 30% from the original top edge.
 */
@property (nonatomic) CGFloat bottom;

/**
 * Specifies the right edge as a percentage of the original image (a float from 0-1).
 * With a value of 0.6 the cropped image will have a right edge that starts 60% from the original left edge.
 */
@property (nonatomic) CGFloat right;

- (instancetype)initWithTop:(CGFloat)top left:(CGFloat)left bottom:(CGFloat)bottom right:(CGFloat)right;

@end
