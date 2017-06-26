//
//  NSDictionary+Clarifai.m
//  Pods
//
//  Created by John Sloan on 4/28/17.
//
//

#import "NSDictionary+Clarifai.h"

@implementation NSDictionary (Clarifai)

- (id)findObjectForKey:(NSString *)key {
  return [self findObjectForKey:key inDictionary:self];
}

- (id)findObjectForKey:(NSString *)key inDictionary:(NSDictionary *)dict {
  if (dict == nil) {
    return nil;
  }
  if ([dict objectForKey:key]) {
    return [dict objectForKey:key];
  } else {
    id object = nil;
    for (NSString *newKey in [dict allKeys]) {
      if ([dict[newKey] isKindOfClass:[NSDictionary class]]) {
        object = [self findObjectForKey:key inDictionary:dict[newKey]];
        if (object) break;
      }
    }
    return object;
  }
}

@end

@implementation NSMutableDictionary (Clarifai)

- (id)findObjectForKey:(NSString *)key {
  return [self findObjectForKey:key inDictionary:self];
}

- (id)findObjectForKey:(NSString *)key inDictionary:(NSDictionary *)dict {
  if (dict == nil) {
    return nil;
  }
  if ([dict objectForKey:key]) {
    return [dict objectForKey:key];
  } else {
    id object = nil;
    for (NSString *newKey in [dict allKeys]) {
      if ([dict[newKey] isKindOfClass:[NSDictionary class]]) {
        object = [self findObjectForKey:key inDictionary:dict[newKey]];
        if (object) break;
      }
    }
    return object;
  }
}

@end
