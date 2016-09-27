//
//  ClarifaiSearchTerm.h
//  ClarifaiApiDemo
//
//  Created by Jack Rogers on 9/16/16.
//  Copyright © 2016 Clarifai, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ClarifaiSearchTerm : NSObject

/** The item being searched. This can be an input, output, or concept */
@property (strong, nonatomic) id searchItem;
/** A boolean value indicating wether the search term should be accross inputs or outputs */
@property (nonatomic) BOOL isInput;

- (instancetype)initWithSearchItem:(id)searchItem isInput:(BOOL)isInput;

@end
