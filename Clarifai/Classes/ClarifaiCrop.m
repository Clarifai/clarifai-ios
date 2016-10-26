//
//  ClarifaiCrop.m
//  Pods
//
//  Created by John Sloan on 10/13/16.
//
//

#import "ClarifaiCrop.h"

@implementation ClarifaiCrop

- (instancetype)initWithTop:(CGFloat)top left:(CGFloat)left bottom:(CGFloat)bottom right:(CGFloat)right {
    self = [super init];
    if (self) {
        self.top = top;
        self.left = left;
        self.bottom = bottom;
        self.right = right;
    }
    return self;
}

@end
