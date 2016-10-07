//
//  ClarifaiImage.h
//  ClarifaiApiDemo
//
//  Created by John Sloan on 9/1/16.
//  Copyright © 2016 Clarifai, Inc. All rights reserved.
//

#import "ClarifaiInput.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ClarifaiImage : ClarifaiInput

/** A crop for media can be specified when adding. Nil otherwise. */
@property CGRect crop;

/** Optionally, you can set a UIImage instead of an ClarifaiInput's mediaURL. Set this using an initializer so that the mediaData parameter is also properly set. */
@property (strong, nonatomic) UIImage *image;

- (instancetype)initWithImage:(UIImage *)image;

/* The concepts array can take ClarifaiConcepts or NSStrings. If it finds strings, it will automatically create concepts named with the given strings. */
- (instancetype)initWithImage:(UIImage *)image andConcepts:(NSArray *)concepts;

@end
