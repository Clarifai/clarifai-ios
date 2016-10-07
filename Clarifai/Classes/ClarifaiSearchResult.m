//
//  ClarifaiSearchResult.m
//  ClarifaiApiDemo
//
//  Created by Jack Rogers on 9/15/16.
//  Copyright © 2016 Clarifai, Inc. All rights reserved.
//

#import "ClarifaiSearchResult.h"

@implementation ClarifaiSearchResult

- (instancetype)initWithDictionary:(NSDictionary *)dict {
  self = [super initWithDictionary:dict[@"input"]];
  if (self) {
    _score = dict[@"score"];
  }
  return self;
}


@end
