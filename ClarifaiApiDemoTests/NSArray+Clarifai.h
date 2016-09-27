//
//  NSArray+Clarifai.h
//  ClarifaiPhotos
//
//  Created by Keith Ito on 4/1/15.
//  Copyright (c) 2015 Clarifai, Inc. All rights reserved.
//

@import Foundation;

typedef id (^CAIMapFunction)(id input);
typedef BOOL (^CAIFilterFunction)(id input);
typedef NSComparisonResult (^CAICompareFunction)(id thing1, id thing2);


@interface NSArray (Clarifai)

/** Creates a new NSArray with the results of calling mapFn on every element. */
- (NSArray *)map:(CAIMapFunction)mapFn;

/** Creates a new NSArray with all elements for which filterFn returns YES. */
- (NSArray *)filter:(CAIFilterFunction)filterFn;

/** Produces the same result as calling filter, then calling map on the result. */
- (NSArray *)filter:(CAIFilterFunction)filterFn map:(CAIMapFunction)mapFn;

/** Builds a dictionary with the key as the result of calling keyFn. */
- (NSDictionary *)asDictionaryUsingKey:(CAIMapFunction)keyFn;

/** Returns an array sorted by the named key, in ascending or descending order. */
- (NSArray *)sortedByKey:(NSString *)key ascending:(BOOL)ascending;

/**
 * Returns an NSArray of NSArrays, each of which are approximately batchSize elements. The size
 * of each batch will be no larger than batchSize, but may be smaller.
 */
- (NSArray *)asBatchesOfSize:(NSInteger)batchSize;

/** Returns a subarray of this NSArray, using the same rules as python slicing. */
- (NSArray *)slicedFrom:(NSInteger)from to:(NSInteger)to;

/** Returns a copy of this array with elements in the same order and duplicates removed. */
- (NSArray *)duplicatesRemoved;

/** Returns a new array with the elements of this array in random order. */
- (NSArray *)shuffled;

/** Returns a random element from the array, or nil if it is empty. */
- (id)randomElement;

/** Performs a binary search on the array with the given compare function. The array must be sorted. */
- (NSInteger)binarySearch:(id)searchItem compareFN:(CAICompareFunction)compareFN;

@end


@interface NSMutableArray (Clarifai)

/** Sorts in place by the named key, in ascending or descending order. */
- (void)sortByKey:(NSString *)key ascending:(BOOL)ascending;

@end
