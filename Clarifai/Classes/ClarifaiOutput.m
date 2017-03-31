//
//  ClarifaiOutput.m
//  ClarifaiApiDemo
//
//  Created by John Sloan on 9/1/16.
//  Copyright © 2016 Clarifai, Inc. All rights reserved.
//

#import "ClarifaiOutput.h"

@implementation ClarifaiOutput

- (instancetype)initWithDictionary:(NSDictionary *)dict {
  self = [super init];
  if (self) {
    
    // let user have access to complete dictionary for customized use.
    _responseDict = dict;
    
    // add link to input, to the output. (contains media like images).
    ClarifaiInput *input = [[ClarifaiInput alloc] initWithDictionary:dict[@"input"]];
    self.input = input;
    
    // check that data dictionary exists.
    if ([dict objectForKey:@"data"] != nil) {
      // add concepts to output, if any.
      ClarifaiModel *model = [[ClarifaiModel alloc] initWithDictionary:dict[@"model"]];
      NSArray *conceptsArray = dict[@"data"][@"concepts"];
      NSMutableArray *concepts = [NSMutableArray array];
      for (NSDictionary *conceptData in conceptsArray) {
        ClarifaiConcept *concept = [[ClarifaiConcept alloc] initWithDictionary:conceptData];
        concept.model = model;
        [concepts addObject:concept];
      }
      self.concepts = concepts;
      
      // add colors to output, if any.
      NSArray *colorsArray = dict[@"data"][@"colors"];
      NSMutableArray *colors = [NSMutableArray array];
      for (NSDictionary *colorData in colorsArray) {
        ClarifaiConcept *color = [[ClarifaiConcept alloc] init];
        color.model = model;
        color.conceptID = colorData[@"raw_hex"];
        color.conceptName = colorData[@"raw_hex"];
        color.score = [colorData[@"value"] floatValue];
        [colors addObject:color];
      }
      self.colors = colors;
      
      // add clusterID if in the dictionary.
      NSArray *clusterArray = dict[@"data"][@"clusters"];
      for (NSDictionary *clusterData in clusterArray) {
        self.clusterID = clusterData[@"id"];
      }
      
      // add embeddings if any.
      NSArray *embeddingsArray = dict[@"data"][@"embeddings"];
      if (embeddingsArray != nil && [embeddingsArray count] > 0) {
        self.embedding = embeddingsArray[0][@"vector"];
      }
    }
  }
  return self;
}
  
@end
