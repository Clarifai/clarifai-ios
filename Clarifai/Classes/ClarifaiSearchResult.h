//
//  ClarifaiSearchResult.h
//  ClarifaiApiDemo
//
//  Created by Jack Rogers on 9/15/16.
//  Copyright © 2016 Clarifai, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ClarifaiInput.h"

/**
 * ClarifaiSearchResults are returned when searching across inputs in your application.
 */
@interface ClarifaiSearchResult : ClarifaiInput

/** The score of the input  */
@property (strong, nonatomic) NSNumber *score;

@end
