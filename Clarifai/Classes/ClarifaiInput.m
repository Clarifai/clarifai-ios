//
//  ClarifaiInput.m
//  ClarifaiApiDemo
//
//  Created by John Sloan on 9/1/16.
//  Copyright © 2016 Clarifai, Inc. All rights reserved.
//

#import "ClarifaiInput.h"
#import "NSArray+Clarifai.h"

@implementation ClarifaiInput

- (instancetype)initWithDictionary:(NSDictionary *)dict {
  
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss'Z'";
  
  self = [super init];
  if (self) {
    _inputID = dict[@"id"];
    _creationDate = [dateFormatter dateFromString:dict[@"created_at"]];
    NSDictionary *data = dict[@"data"];
    NSDictionary *image = data[@"image"];
    if (image) {
      _mediaURL = image[@"url"];
    }
    
    NSArray *conceptsArray = data[@"concepts"];
    NSMutableArray *concepts = [[NSMutableArray alloc] init];
    if (conceptsArray) {
      for (NSDictionary *conceptDict in conceptsArray) {
        ClarifaiConcept *concept = [[ClarifaiConcept alloc] initWithDictionary:conceptDict];
        [concepts addObject:concept];
      }
      _concepts = concepts;
    }
    
    _metadata = data[@"metadata"];
  }
  return self;
}

- (instancetype)initWithURL:(NSString *)url {
  self = [super init];
  if (self) {
    self.mediaURL = url;
  }
  return self;
}

- (instancetype)initWithURL:(NSString *)URL andConcepts:(NSArray *)concepts {
  self = [super init];
  if (self) {
    self.mediaURL = URL;
    self.concepts = [concepts map:^(id concept) {
      if ([concept isKindOfClass:[NSString class]]) {
        return [[ClarifaiConcept alloc] initWithConceptName:concept];
      } else {
        return (ClarifaiConcept *)concept;
      }
    }];
  }
  return self;
}


@end
