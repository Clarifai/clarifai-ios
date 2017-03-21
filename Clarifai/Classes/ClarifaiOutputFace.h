//
//  ClarifaiConcept.h
//  Clarifai API Client
//
//  Created by John Sloan on 3/20/17.
//  Copyright © 2017 Clarifai, Inc. All rights reserved.
//

#import "ClarifaiOutput.h"
#import "ClarifaiOutputRegion.h"

@interface ClarifaiOutputFace : ClarifaiOutput

/** The bounding boxes of all faces detected. */
@property (strong,nonatomic) NSArray<ClarifaiOutputRegion *> *faces;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end
