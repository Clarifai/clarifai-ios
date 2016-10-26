//
//  ClarifaiModelVersion.h
//  ClarifaiApiDemo
//
//  Created by John Sloan on 9/15/16.
//  Copyright © 2016 Clarifai, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * ClarifaiModelVersion contains version info for models.
 */
@interface ClarifaiModelVersion : NSObject

/** The version id of the model. */
@property (strong, nonatomic) NSString *versionID;

/** The data the version was created. */
@property (strong, nonatomic) NSDate *createdAt;

/** The status code of this version of the model. */
@property (strong, nonatomic) NSNumber *statusCode;

/** A description of the status of this version of the model (i.e "Model not yet trained"). */
@property (strong, nonatomic) NSString *statusDescription;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end
