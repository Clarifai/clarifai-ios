//
//  ClarifaiSearchTerm.h
//  ClarifaiApiDemo
//
//  Created by Jack Rogers on 9/16/16.
//  Copyright © 2016 Clarifai, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * ClarifaiSearchTerm is used to construct a search query across your application. It can specify the item to search as an input or an output.
 */
@interface ClarifaiSearchTerm : NSObject

/** The item being searched. This can be an input, output, or concept */
@property (strong, nonatomic) id searchItem;
/** A boolean value indicating wether the search term should be accross inputs or outputs */
@property (nonatomic) BOOL isInput;

- (instancetype)initWithSearchItem:(id)searchItem isInput:(BOOL)isInput;

@end
