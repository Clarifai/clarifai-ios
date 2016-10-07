//
//  ClarifaiImage.m
//  ClarifaiApiDemo
//
//  Created by John Sloan on 9/1/16.
//  Copyright © 2016 Clarifai, Inc. All rights reserved.
//

#import "ClarifaiImage.h"
#import "NSArray+Clarifai.h"

@implementation ClarifaiImage

- (instancetype)initWithScoredImageDictionary:(NSDictionary *)dict {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss'Z'";
    
    self = [super init];
    if (self) {
        NSDictionary *image = dict[@"image"];
        self.inputID = image[@"id"];
        self.mediaURL = dict[@"url"];
        self.creationDate = [dateFormatter dateFromString:dict[@"created_at"]];
    }
    return self;
}

- (instancetype)initWithImage:(UIImage *)image {
    self = [super init];
    if (self) {
        self.image = image;
        self.mediaData = UIImageJPEGRepresentation(image, 1.0);
    }
    return self;
}

- (instancetype)initWithImage:(UIImage *)image andConcepts:(NSArray *)concepts {
    self = [super init];
    if (self) {
        self.image = image;
        self.mediaData = UIImageJPEGRepresentation(image, 1.0);
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
