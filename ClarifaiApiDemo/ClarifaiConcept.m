//
//  ClarifaiConcept.m
//  ClarifaiApiDemo
//
//  Created by John Sloan on 9/1/16.
//  Copyright © 2016 Clarifai, Inc. All rights reserved.
//

#import "ClarifaiConcept.h"

@implementation ClarifaiConcept

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        _conceptID = dict[@"id"];
        _conceptName = dict[@"name"];
        _appID = dict[@"app_id"];

        if (dict[@"value"] != nil && dict[@"value"] != [NSNull null]) {
            _score = [dict[@"value"] floatValue];
        }
    }
    return self;
}

- (instancetype)initWithConceptName:(NSString *)conceptName {
  self = [super init];
  if (self) {
    _conceptName = conceptName;
    _conceptID = conceptName;
    
    //default to one(true) when adding with an input.
    //This means the concept is positively associated with the input.
    _score = 1;
  }
  return self;
}

- (instancetype)initWithConceptID:(NSString *)conceptID {
  self = [super init];
  if (self) {
    _conceptID = conceptID;
    _score = 1;
  }
  return self;
}


@end
