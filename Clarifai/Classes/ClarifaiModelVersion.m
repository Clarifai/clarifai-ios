//
//  ClarifaiModelVersion.m
//  ClarifaiApiDemo
//
//  Created by John Sloan on 9/15/16.
//  Copyright © 2016 Clarifai, Inc. All rights reserved.
//

#import "ClarifaiModelVersion.h"

@implementation ClarifaiModelVersion

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss'Z'";
    self = [super init];
    if (self) {
        _versionID = dict[@"id"];
        _createdAt = [dateFormatter dateFromString:dict[@"created_at"]];
        _statusCode = dict[@"status"][@"code"];
        _statusDescription = dict[@"status"][@"description"];
    }
    return self;
}

@end
