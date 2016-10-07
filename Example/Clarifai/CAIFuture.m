//
//  CAIFuture.m
//

#import "CAIFuture.h"

@interface CAIFuture ()
@property (strong, nonatomic) id result;
@property (strong, nonatomic) dispatch_semaphore_t semaphore;
@end

@implementation CAIFuture

- (instancetype)init {
  return [self initWithDefault:nil];
}

- (instancetype)initWithDefault:(id)defaultResult {
  if (self = [super init]) {
    _result = defaultResult;
    _semaphore = dispatch_semaphore_create(0);
  }
  return self;
}

- (id)getResult {
  dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
  return _result;
}

- (id)getResultWithTimeout:(NSTimeInterval)timeout {
  dispatch_semaphore_wait(_semaphore,
                          dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeout * NSEC_PER_SEC)));
  return _result;
}

- (void)setResult:(id)result {
  _result = result;
  dispatch_semaphore_signal(_semaphore);
}

- (void)setResult:(id)result error:(NSError *)error {
  _result = result;
  _error = error;
  dispatch_semaphore_signal(_semaphore);
}

@end
