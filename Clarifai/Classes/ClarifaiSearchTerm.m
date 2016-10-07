//
//  ClarifaiSearchTerm.m
//  ClarifaiApiDemo
//
//  Created by Jack Rogers on 9/16/16.
//  Copyright © 2016 Clarifai, Inc. All rights reserved.
//

#import "ClarifaiSearchTerm.h"

@implementation ClarifaiSearchTerm

- (instancetype)initWithSearchItem:(id)searchItem isInput:(BOOL)isInput {
  self = [super init];
  if (self) {
    _searchItem = searchItem;
    _isInput = isInput;
  }
  return self;
}

@end
