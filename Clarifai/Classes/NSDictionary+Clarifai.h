//
//  NSDictionary+Clarifai.h
//  Pods
//
//  Created by John Sloan on 4/28/17.
//
//

@import Foundation;

@interface NSDictionary (Clarifai)

- (id)findObjectForKey:(NSString *)key;

@end


@interface NSMutableDictionary (Clarifai)

- (id)findObjectForKey:(NSString *)key;

@end
