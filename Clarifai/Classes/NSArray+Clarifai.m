//
//  NSArray+Clarifai.m
//  ClarifaiPhotos
//
//  Created by Keith Ito on 4/1/15.
//  Copyright (c) 2015 Clarifai, Inc. All rights reserved.
//

#import "NSArray+Clarifai.h"

@implementation NSArray (Clarifai)

- (NSArray *)map:(CAIMapFunction)mapFn {
  NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:self.count];
  for (id item in self) {
    id mapped = mapFn(item);
    if (mapped != nil) {
      [result addObject:mapped];
    }
  }
  return result;
}

- (NSArray *)filter:(CAIFilterFunction)filterFn {
  return [self filter:filterFn map:^(id item) { return item; }];
}

- (NSArray *)filter:(CAIFilterFunction)filterFn map:(CAIMapFunction)mapFn {
  NSMutableArray *result = [[NSMutableArray alloc] init];
  for (id item in self) {
    if (filterFn(item)) {
      id mapped = mapFn(item);
      if (mapped != nil) {
        [result addObject:mapped];
      }
    }
  }
  return result;
}

- (NSDictionary *)asDictionaryUsingKey:(CAIMapFunction)keyFn {
  NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:self.count];
  for (id item in self) {
    id key = keyFn(item);
    if (key != nil) {
      dict[key] = item;
    }
  }
  return dict;
}

- (NSArray *)asBatchesOfSize:(NSInteger)batchSize {
  if (batchSize <= 0) {
    return nil;
  }
  NSInteger numBatches = (self.count + batchSize - 1) / batchSize;
  if (numBatches == 0) {
    return @[];
  }
  NSInteger actualBatchSize = (self.count + numBatches - 1) / numBatches;
  NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:numBatches];
  for (NSInteger i = 0; i < self.count; i += actualBatchSize) {
    [result addObject:[self slicedFrom:i to:i + actualBatchSize]];
  }
  return result;
}

- (NSArray *)sortedByKey:(NSString *)key ascending:(BOOL)ascending {
  NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:key ascending:ascending];
  return [self sortedArrayUsingDescriptors:@[descriptor]];
}

- (NSArray *)slicedFrom:(NSInteger)from to:(NSInteger)to {
  // Translate negative values into offsets from the end (a la Python)
  if (from < 0) {
    from += self.count;
  }
  if (to < 0) {
    to += self.count;
  }
  
  // Clamp:
  from = MAX(0, MIN((NSInteger)self.count, from));
  to = MAX(0, MIN((NSInteger)self.count, to));
  if (from == 0 && to == self.count) {
    return self;
  } else {
    return [self subarrayWithRange:NSMakeRange(from, MAX(0, to - from))];
  }
}

- (NSArray *)duplicatesRemoved {
  return [[NSOrderedSet orderedSetWithArray:self] array];
}

- (NSArray *)shuffled {
  NSMutableArray *shuffled = [[NSMutableArray alloc] initWithArray:self];
  NSInteger n = shuffled.count;
  for (NSInteger i = n - 1; i > 0; i--) {
    [shuffled exchangeObjectAtIndex:i withObjectAtIndex:arc4random_uniform((int)i + 1)];
  }
  return shuffled;
}

- (id)randomElement {
  if (self.count == 0) {
    return nil;
  } else {
    NSUInteger randomIndex = arc4random_uniform((int)self.count);
    return [self objectAtIndex:randomIndex];
  }
}

- (NSInteger)binarySearch:(id)searchItem compareFN:(CAICompareFunction)compareFN {
  if (searchItem == nil)
    return NSNotFound;
  return [self binarySearch:searchItem minIndex:0 maxIndex:[self count] - 1 compareFN:compareFN];
}

- (NSInteger)binarySearch:(id)searchItem minIndex:(NSInteger)minIndex maxIndex:(NSInteger)maxIndex compareFN:(CAICompareFunction)compareFN {
  if (maxIndex < minIndex)
    return NSNotFound;
  
  NSInteger midIndex = (minIndex + maxIndex) / 2;
  id itemAtMidIndex = [self objectAtIndex:midIndex];
  
  NSComparisonResult comparison = compareFN(searchItem, itemAtMidIndex);
  if (comparison == NSOrderedSame)
    return midIndex;
  else if (comparison == NSOrderedDescending)
    return [self binarySearch:searchItem minIndex:minIndex maxIndex:midIndex - 1 compareFN:compareFN];
  else
    return [self binarySearch:searchItem minIndex:midIndex + 1 maxIndex:maxIndex compareFN:compareFN];
}

@end


@implementation NSMutableArray (Clarifai)

- (void)sortByKey:(NSString *)key ascending:(BOOL)ascending {
  NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:key ascending:ascending];
  [self sortUsingDescriptors:@[descriptor]];
}

@end
