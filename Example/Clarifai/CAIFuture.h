//
//  CAIFuture.h
//

@import Foundation;

/**
 * Represents the result of an asynchronous computation. Methods are provided to set the result of
 * the computation and block until the computation is complete.
 */
@interface CAIFuture : NSObject
@property (strong, nonatomic) NSError *error;

/** Initializes with a nil default value. */
- (instancetype)init;

/** Initializes with a given default result. */
- (instancetype)initWithDefault:(id)defaultResult;

/** Blocks until the task is done, then returns the value. */
- (id)getResult;

/** Blocks until the task is done or timeout expires, then returns the value. */
- (id)getResultWithTimeout:(NSTimeInterval)timeout;

/** Sets the result and unblocks anyone waiting. */
- (void)setResult:(id)value;

/** Sets the result and error and unblocks anyone waiting. Either can be nil. */
- (void)setResult:(id)result error:(NSError *)error;

@end
