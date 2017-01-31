//
//  CLImage+Clarifai.h
//  GestureControl
//
//  Created by Garrett Davidson on 11/20/16.
//  Copyright © 2016 Garrett Davidson. All rights reserved.
//

@import Foundation;

#if TARGET_OS_IPHONE | TARGET_OS_SIMULATOR
#import <UIKit/UIKit.h>
#define CLImage UIImage

#else
#import <AppKit/AppKit.h>
#define CLImage NSImage

#endif

@interface CLImage (Clarifai)

- (NSData *)dataRepresentation;

@end
