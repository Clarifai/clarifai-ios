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
    
    // add reference to original input. (contains media like images).
    NSDictionary *inputDict = [dict findObjectForKey:@"input"];
    if (inputDict != nil) {
      ClarifaiInput *input = [[ClarifaiInput alloc] initWithDictionary:inputDict];
      self.input = input;
    }
    
    // add concepts to output, if any.
    NSDictionary *modelDict = [dict findObjectForKey:@"model"];
    NSArray *conceptsArray = [dict findObjectForKey:@"concepts"];
    ClarifaiModel *model = [[ClarifaiModel alloc] initWithDictionary:modelDict];
    NSMutableArray *concepts = [NSMutableArray array];
    for (NSDictionary *conceptData in conceptsArray) {
      ClarifaiConcept *concept = [[ClarifaiConcept alloc] initWithDictionary:conceptData];
      concept.model = model;
      [concepts addObject:concept];
    }
    self.concepts = concepts;
    
    // add colors to output, if any.
    NSArray *colorsArray = [dict findObjectForKey:@"colors"];
    NSMutableArray *colors = [NSMutableArray array];
    for (NSDictionary *colorData in colorsArray) {
      ClarifaiConcept *color = [[ClarifaiConcept alloc] init];
      color.model = model;
      color.conceptID = [colorData findObjectForKey:@"raw_hex"];
      color.conceptName = [colorData findObjectForKey:@"name"];
      color.score = [[colorData findObjectForKey:@"value"] floatValue];
      [colors addObject:color];
    }
    self.colors = colors;
    
    // add clusterID if in the dictionary.
    NSArray *clusterArray = [dict findObjectForKey:@"clusters"];
    for (NSDictionary *clusterData in clusterArray) {
      self.clusterID = clusterData[@"id"];
    }
    
    // add embeddings if any.
    NSArray *embeddingsArray = [dict findObjectForKey:@"embeddings"];
    if (embeddingsArray != nil && [embeddingsArray count] > 0) {
      self.embedding = embeddingsArray[0][@"vector"];
    }
    
    // initialize regions array.
    self.regions = [NSArray array];
  }
  return self;
}

@end
