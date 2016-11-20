//
//  CLImage+Clarifai.m
//  GestureControl
//
//  Created by Garrett Davidson on 11/20/16.
//  Copyright © 2016 Garrett Davidson. All rights reserved.
//

#import "CLImage+Clarifai.h"

@implementation CLImage (Clarifai)

- (NSData *)dataRepresentation {
#if TARGET_OS_IPHONE | TARGET_OS_SIMULATOR
    return UIImageJPEGRepresentation(self, 1.0);

#else
    return self.TIFFRepresentation;

#endif
}

@end
