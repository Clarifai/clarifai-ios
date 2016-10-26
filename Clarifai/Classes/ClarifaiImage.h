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
#import "ClarifaiCrop.h"

/**
 * ClarifaiImage is a subclass of ClarifaiInput used specifically for images.
 */
@interface ClarifaiImage : ClarifaiInput

/** A crop for media can be specified when adding. Nil otherwise. */
@property ClarifaiCrop *crop;

/** Optionally, you can set a UIImage instead of a ClarifaiInput's mediaURL. Set this using an initializer so that the mediaData parameter is also properly set. */
@property (strong, nonatomic) UIImage *image;

- (instancetype)initWithImage:(UIImage *)image;

- (instancetype)initWithImage:(UIImage *)image andCrop:(ClarifaiCrop *)crop;

/* The concepts array can take ClarifaiConcepts or NSStrings. If it finds strings, it will automatically create concepts named with the given strings. */
- (instancetype)initWithImage:(UIImage *)image andConcepts:(NSArray *)concepts;

- (instancetype)initWithImage:(UIImage *)image crop:(ClarifaiCrop *)crop andConcepts:(NSArray *)concepts;

- (instancetype)initWithURL:(NSString *)url andCrop:(ClarifaiCrop *)crop;

- (instancetype)initWithURL:(NSString *)url crop:(ClarifaiCrop *)crop andConcepts:(NSArray *)concepts;
@end
