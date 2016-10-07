//
//  ClarifaiFace.h
//  ClarifaiApiDemo
//
//  Created by John Sloan on 9/1/16.
//  Copyright © 2016 Clarifai, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ClarifaiFace : NSObject

/** Coordinates of the face detected. */
@property (nonatomic) CGRect faceCoords;

@end
