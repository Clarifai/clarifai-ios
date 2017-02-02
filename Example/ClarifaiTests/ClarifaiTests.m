//
//  ClarifaiApiDemoTests.m
//  ClarifaiApiDemoTests
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "ClarifaiApp.h"
#import "CAIFuture.h"
#import "ClarifaiSearchResult.h"
#import "ClarifaiSearchTerm.h"

@interface ClarifaiApiDemoTests : XCTestCase
@property ClarifaiApp *app;
@property NSString *runningImageID;
@property NSString *runningConceptID;
@property NSString *runningModelID;
@property NSString *runningVersionID;
@property CGFloat conCount;
@end

@implementation ClarifaiApiDemoTests

- (void)setUp {
  _app = [[ClarifaiApp alloc] initWithAppID:@""
                                  appSecret:@""];
}

// TEST INPUTS
- (void)testAddInputs {
  CAIFuture *future = [[CAIFuture alloc] init];
  
  //create first image and concept.
  ClarifaiConcept *concept1 = [[ClarifaiConcept alloc] initWithConceptName:@"dogg"];
  concept1.score = 0;
  ClarifaiCrop *crop = [[ClarifaiCrop alloc] initWithTop:0.2 left:0.3 bottom:0.7 right:0.8];
  ClarifaiImage *img1 = [[ClarifaiImage alloc] initWithURL:@"https://samples.clarifai.com/metro-north.jpg" andConcepts:@[concept1]];
  img1.allowDuplicateURLs = YES;
  
  //create second image and concept.
  ClarifaiConcept *concept2 = [[ClarifaiConcept alloc] initWithConceptName:@"ggod"];
  concept2.score = 1;
  ClarifaiImage *img2 = [[ClarifaiImage alloc] initWithURL:@"http://www.pumapedia.com/wp-content/uploads/2012/10/puma-roca.jpg" crop:crop andConcepts:@[concept2]];
  img2.metadata = @{@"metagurz":@"burf!"};
  img2.allowDuplicateURLs = YES;
  
  [_app addInputs:@[img1,img2] completion:^(NSArray<ClarifaiInput *> *inputs, NSError *error) {
    XCTAssert(error == nil);
    ClarifaiInput *input1 = inputs[0];
    ClarifaiInput *input2 = inputs[1];
    
    // set runningImageID for later tests.
    _runningImageID = input1.inputID;
    XCTAssert(input1.concepts[0].score == 0);
    XCTAssert([input1.concepts[0].conceptName isEqualToString:@"dogg"]);
    XCTAssert(input2.concepts[0].score == 1);
    XCTAssert([input2.concepts[0].conceptName isEqualToString:@"ggod"]);
    XCTAssert([input2.metadata[@"metagurz"] isEqualToString:@"burf!"]);
    [future setResult:@(YES)];
  }];
  [future getResult];
}

- (void)testGetInputs {
  CAIFuture *future = [[CAIFuture alloc] init];
  [self testAddInputs];
  [_app getInputsOnPage:1 pageSize:30 completion:^(NSArray<ClarifaiInput *> *inputs, NSError *error) {
    XCTAssert(error == nil);
    XCTAssert([inputs count] > 0);
    XCTAssert(inputs[0].inputID != nil);
    [future setResult:@(YES)];
  }];
  [future getResult];
}

- (void)testGetInputByID {
  CAIFuture *future = [[CAIFuture alloc] init];
  [self testAddInputs];
  [_app getInput:_runningImageID completion:^(ClarifaiInput *input, NSError *error) {
    XCTAssert(error == nil);
    XCTAssert([_runningImageID isEqualToString:input.inputID]);
    [future setResult:@(YES)];
  }];
  
  [future getResult];
}

- (void)testGetInputStatus {
  CAIFuture *future = [[CAIFuture alloc] init];
  [_app getInputsStatus:^(int numProcessed, int numToProcess, int errors, NSError *error) {
    XCTAssert(error == nil);
    [future setResult:@(YES)];
  }];
  
  [future getResult];
}

- (void)testDeleteInputByID {
  CAIFuture *future = [[CAIFuture alloc] init];
  [self testAddInputs];
  [_app deleteInput:_runningImageID completion:^(NSError *error) {
    XCTAssert(error == nil);
    [_app getInput:_runningImageID completion:^(ClarifaiInput *input, NSError *error) {
      //should be error if input was properly deleted.
      XCTAssert(error != nil);
      [future setResult:@(YES)];
    }];
  }];
  
  [future getResult];
}

- (void)testDeleteInputByIDListInputs {
  CAIFuture *future = [[CAIFuture alloc] init];
  [self testAddInputs];
  ClarifaiInput *input = [[ClarifaiInput alloc] init];
  input.inputID = _runningImageID;
  [_app deleteInputsByIDList:@[input] completion:^(NSError *error) {
    XCTAssert(error == nil);
    //poll to check for input until deletion completes.
    [self pollForInputWithTimeout:20 completion:^(NSError *error) {
      XCTAssert(error == nil);
      [future setResult:@(YES)];
    }];
  }];
  
  [future getResult];
}

- (void)testDeleteInputByIDListStrings {
  CAIFuture *future = [[CAIFuture alloc] init];
  [self testAddInputs];
  [_app deleteInputsByIDList:@[_runningImageID] completion:^(NSError *error) {
    XCTAssert(error == nil);
    //poll to check for input until deletion completes.
    [self pollForInputWithTimeout:20 completion:^(NSError *error) {
      XCTAssert(error == nil);
      [future setResult:@(YES)];
    }];
  }];
  
  [future getResult];
}

- (void)testDeleteAllInputs {
  CAIFuture *future = [[CAIFuture alloc] init];
  [self testAddInputs];
  [_app deleteAllInputs:^(NSError *error) {
    XCTAssert(error == nil);
    //poll until deletion completes, getinput returns 404 error.
    [self pollForInputWithTimeout:20 completion:^(NSError *error) {
      XCTAssert(error == nil);
      [future setResult:@(YES)];
    }];
  }];
  [future getResult];
}

- (void) pollForInputWithTimeout:(NSInteger)attempts completion:(ClarifaiRequestCompletion)completion {
  if (attempts > 0) {
    [_app getInput:_runningImageID completion:^(ClarifaiInput *input, NSError *error) {
      if (input == nil && error != nil) {
        NSDictionary *userinfo = [error userInfo];
        NSHTTPURLResponse *response = userinfo[@"com.alamofire.serialization.response.error.response"];
        NSInteger statusCode = [response statusCode];
        if (statusCode == (NSInteger)404) {
          // error code was 404, resource does not exist. input was deleted.
          completion(nil);
        } else {
          // some other error, pass on to completion.
          completion(error);
        }
      } else if (input != nil && error == nil) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
          [self pollForInputWithTimeout:attempts-1 completion:completion];
        });
      }
    }];
  } else {
    // timed out, all attempts completed.
    NSError *error = [[NSError alloc] initWithDomain:@"com.clarifai.ClarifaiClient" code:(NSInteger)408 userInfo:@{@"description":@"Request timed out. Input still existed after all attempts."}];
    completion(error);
  }
}

- (void)testSearchWithMetadata {
  CAIFuture *future = [[CAIFuture alloc] init];
  [self testAddInputs];
  [_app searchByMetadata:@{@"metagurz":@"burf!"} page:@1 perPage:@20 isInput:YES completion:^(NSArray<ClarifaiSearchResult *> *results, NSError *error) {
    XCTAssert([results[0].metadata[@"metagurz"] isEqualToString:@"burf!"]);
    [future setResult:@(YES)];
  }];
  
  [future getResult];
}

- (void)testSearchWithImageData {
  CAIFuture *future = [[CAIFuture alloc] init];
  [self testAddInputs];
  ClarifaiImage *image = [[ClarifaiImage alloc] initWithImage:[UIImage imageNamed:@"geth.jpg"]];
  ClarifaiSearchTerm *searchTerm = [[ClarifaiSearchTerm alloc] initWithSearchItem:image isInput:NO];
  [_app search:@[searchTerm] page:@1 perPage:@20 language:nil completion:^(NSArray<ClarifaiSearchResult *> *results, NSError *error) {
    XCTAssert([results count] > 0);
    [future setResult:@(YES)];
  }];
  [future getResult];
}

-(void) testLatency {
  CAIFuture *future = [[CAIFuture alloc] init];
  NSLog(@"ENTER TEST");
  ClarifaiApp *app = [[ClarifaiApp alloc] initWithAppID:@"TeOho5qU8wU-443qiOA2XeEFR8tEp_nTkOlE70sD"
                                  appSecret:@"5ruPRsLvpLLwA8WkdOHfGti6n77SqIOVQe-ZrzqA"];
  
  ClarifaiImage *image = [[ClarifaiImage alloc] initWithImage:[UIImage imageNamed:@"geth.jpg"]];
  [app getModelByName:@"food-items-v1.0" completion:^(ClarifaiModel *model, NSError *error) {
    [model predictOnImages:@[image] completion:^(NSArray<ClarifaiOutput *> *outputs, NSError *error) {
      NSLog(@"response!");
      [future setResult:@(YES)];
    }];
  }];
  [future getResult];
}

-(void) testMergeConceptsBulk {
  CAIFuture *future = [[CAIFuture alloc] init];
  [self testAddInputs];
  ClarifaiConcept *newConcept = [[ClarifaiConcept alloc] initWithConceptID:@"tree"];
  [_app getInput:_runningImageID completion:^(ClarifaiInput *input, NSError *error) {
    XCTAssert(error == nil);
    XCTAssert(input.inputID != nil);
    // Add tree concept to each current input's concept list.
    NSMutableArray *newConceptList = [NSMutableArray arrayWithArray:input.concepts];
    [newConceptList addObject:newConcept];
    input.concepts = newConceptList;
    
    // Merge the new list for one or more inputs.
    [_app mergeConceptsForInputs:@[input] completion:^(NSArray<ClarifaiInput *> *inputs, NSError *error) {
      NSLog(@"updated inputs: %@", inputs);
      XCTAssert(error == nil);
      XCTAssert([inputs count] > 0);
      XCTAssert(inputs[0].inputID != nil);
      [future setResult:@(YES)];
    }];
  }];
  [future getResult];
}

//- (void)testAddInputsCreateModel {
//  CAIFuture *future = [[CAIFuture alloc] init];
//  ClarifaiImage *candelabra = [[ClarifaiImage alloc] initWithURL:@"http://i.imgur.com/rbJgWn1.jpg"
//                                                     andConcepts:@[@"test_candelabra"]];
//  ClarifaiImage *menorah = [[ClarifaiImage alloc] initWithURL:@"http://i.imgur.com/2TgEzZ9.jpg"
//                                                  andConcepts:@[@"test_menorah"]];
//  
//  candelabra.allowDuplicateURLs = YES;
//  menorah.allowDuplicateURLs = YES;
//  
//  __weak ClarifaiApp *app = _app;
//  [app addInputs:@[candelabra, menorah] completion:^(NSArray<ClarifaiInput *> *inputs, NSError *error) {
//    assert(inputs != nil);
//    [app createModel:@[@"test_candelabra", @"test_menorah"]
//                name:@"candelabra"
//             modelID:
//conceptsMutuallyExclusive:NO
//   closedEnvironment:NO
//          completion:^(ClarifaiModel *model, NSError *error) {
//            assert(model != nil);
//            _runningModelID = model.modelID;
//            [model train:^(ClarifaiModelVersion *modelVersion, NSError *error) {
//              assert(modelVersion != nil);
//              XCTAssert([modelVersion.statusCode longValue] == (long)21100);
//              [future setResult:@(YES)];
//            }];
//          }];
//  }];
//  [future getResult];
//}

//- (void)testPredictCandelabraCustomModel {
//  CAIFuture *future = [[CAIFuture alloc] init];
//  ClarifaiImage *candelabra2 = [[ClarifaiImage alloc]
//                                initWithURL:@"http://d28xhcgddm1buq.cloudfront.net/product-images/candelabras-5-candle-13x-24-3_260.jpg"];
//  ClarifaiImage *puma = [[ClarifaiImage alloc]
//                         initWithURL:@"http://www.pumapedia.com/wp-content/uploads/2012/10/puma-roca.jpg"];
//  
//  //change this to search for model by name
//  [_app getModelByID:@"acbaee6284e94d8882267b1db4d2aa89" completion:^(ClarifaiModel *model, NSError *error) {
//    assert(model != nil);
//    [model predictOnImages:@[candelabra2, puma]
//                completion:^(NSArray<ClarifaiSearchResult *> *outputs, NSError *error) {
//                  XCTAssert(outputs != nil);
//                  [future setResult:@(YES)];
//                }];
//  }];
//  [future getResult];
//}

- (void)testMergeConceptsToInput {
  CAIFuture *future = [[CAIFuture alloc] init];
  [self testAddInputs];
  ClarifaiConcept *concept = [[ClarifaiConcept alloc] initWithConceptName:@"cat"];
  concept.score = 0;
  [_app mergeConcepts:@[concept] forInputWithID:_runningImageID completion:^(ClarifaiInput *input, NSError *error) {
    XCTAssert(error == nil);
    bool cat = NO;
    bool dogg = NO;
    for (ClarifaiConcept *concept in input.concepts) {
      if ([concept.conceptID  isEqualToString: @"cat"]) {
        cat = YES;
      } else if ([concept.conceptID  isEqualToString: @"dogg"]) {
        dogg = YES;
      }
    }
    XCTAssert(cat);
    XCTAssert(dogg);
    [future setResult:@(YES)];
  }];
  [future getResult];
}

- (void)testMergeConceptsForInputs {
  CAIFuture *future = [[CAIFuture alloc] init];
  [self testAddInputs];
  [_app getInputsOnPage:1 pageSize:30 completion:^(NSArray<ClarifaiInput *> *inputs, NSError *error) {
    if (inputs.count >= 2) {
      ClarifaiInput *input1 = inputs[0];
      ClarifaiInput *input2 = inputs[1];
      ClarifaiConcept *concept = [[ClarifaiConcept alloc] initWithConceptName:@"cat"];
      input1.concepts = @[concept];
      input2.concepts = @[concept];
      [_app mergeConceptsForInputs:@[input1,input2] completion:^(NSArray<ClarifaiInput *> *inputs, NSError *error) {
        XCTAssert(error == nil);
        bool catInput1 = NO;
        bool catInput2 = NO;
        for (ClarifaiConcept *concept in inputs[0].concepts) {
          if ([concept.conceptID  isEqualToString: @"cat"]) {
            catInput1 = YES;
          }
        }
        for (ClarifaiConcept *concept in inputs[1].concepts) {
          if ([concept.conceptID  isEqualToString: @"cat"]) {
            catInput2 = YES;
          }
        }
        XCTAssert(catInput1);
        XCTAssert(catInput2);
        [future setResult:@(YES)];
      }];
    }
  }];
  [future getResult];
}

- (void)testSetConceptsForInput {
  CAIFuture *future = [[CAIFuture alloc] init];
  [self testAddInputs];
  ClarifaiConcept *concept = [[ClarifaiConcept alloc] initWithConceptName:@"cat"];
  concept.score = 0;
  [_app setConcepts:@[concept] forInputWithID:_runningImageID completion:^(ClarifaiInput *input, NSError *error) {
    XCTAssert(error == nil);
    bool cat = NO;
    bool otherConcepts = NO; // should be no others after overwrite
    for (ClarifaiConcept *concept in input.concepts) {
      if ([concept.conceptID  isEqualToString: @"cat"]) {
        cat = YES;
      } else {
        otherConcepts = YES;
      }
    }
    XCTAssert(cat);
    XCTAssert(!otherConcepts);
    [future setResult:@(YES)];
  }];
  [future getResult];
}

- (void)testSetConceptsForInputs {
  CAIFuture *future = [[CAIFuture alloc] init];
  [self testAddInputs];
  [_app getInputsOnPage:1 pageSize:30 completion:^(NSArray<ClarifaiInput *> *inputs, NSError *error) {
    if (inputs.count >= 2) {
      ClarifaiInput *input1 = inputs[0];
      ClarifaiInput *input2 = inputs[1];
      ClarifaiConcept *concept = [[ClarifaiConcept alloc] initWithConceptName:@"cat"];
      input1.concepts = @[concept];
      input2.concepts = @[concept];
      [_app setConceptsForInputs:@[input1,input2] completion:^(NSArray<ClarifaiInput *> *inputs, NSError *error) {
        XCTAssert(error == nil);
        bool catInput1 = NO;
        bool catInput2 = NO;
        bool otherConcepts = NO; // should be no others after overwrite
        for (ClarifaiConcept *concept in inputs[0].concepts) {
          if ([concept.conceptID  isEqualToString: @"cat"]) {
            catInput1 = YES;
          } else {
            otherConcepts = YES;
          }
        }
        for (ClarifaiConcept *concept in inputs[1].concepts) {
          if ([concept.conceptID  isEqualToString: @"cat"]) {
            catInput2 = YES;
          } else {
            otherConcepts = YES;
          }
        }
        XCTAssert(catInput1);
        XCTAssert(catInput2);
        XCTAssert(!otherConcepts);
        [future setResult:@(YES)];
      }];
    }
  }];
  [future getResult];
}

- (void)testDeleteConceptsFromInput {
  CAIFuture *future = [[CAIFuture alloc] init];
  [self testSetConceptsForInput];
  ClarifaiConcept *concept = [[ClarifaiConcept alloc] initWithConceptName:@"cat"];
  [_app deleteConcepts:@[concept] forInputWithID:_runningImageID completion:^(ClarifaiInput *input, NSError *error) {
    XCTAssert(error == nil);
    bool cat = NO;
    for (ClarifaiConcept *concept in input.concepts) {
      if ([concept.conceptID  isEqualToString: @"cat"]) {
        cat = YES;
      }
    }
    XCTAssert(!cat);
    [future setResult:@(YES)];
  }];
  [future getResult];
}

- (void)testDeleteConceptsForInputs {
  CAIFuture *future = [[CAIFuture alloc] init];
  [self testSetConceptsForInputs];
  [_app getInputsOnPage:1 pageSize:30 completion:^(NSArray<ClarifaiInput *> *inputs, NSError *error) {
    if (inputs.count >= 2) {
      ClarifaiInput *input1 = inputs[0];
      ClarifaiInput *input2 = inputs[1];
      ClarifaiConcept *concept = [[ClarifaiConcept alloc] initWithConceptName:@"cat"];
      input1.concepts = @[concept];
      input2.concepts = @[concept];
      [_app deleteConceptsForInputs:@[input1,input2] completion:^(NSArray<ClarifaiInput *> *inputs, NSError *error) {
        XCTAssert(error == nil);
        bool catInput1 = NO;
        bool catInput2 = NO;
        for (ClarifaiConcept *concept in inputs[0].concepts) {
          if ([concept.conceptID  isEqualToString: @"cat"]) {
            catInput1 = YES;
          }
        }
        for (ClarifaiConcept *concept in inputs[1].concepts) {
          if ([concept.conceptID  isEqualToString: @"cat"]) {
            catInput2 = YES;
          }
        }
        XCTAssert(!catInput1);
        XCTAssert(!catInput2);
        [future setResult:@(YES)];
      }];
    }
  }];
  [future getResult];
}

- (void)testSearchByImageURL {
  CAIFuture *future = [[CAIFuture alloc] init];
  ClarifaiImage *image = [[ClarifaiImage alloc] initWithURL:@"http://thedigitalstory.com/2012/07/27/Train%20Tracks%20P7242542%20Retina.jpg"];
  ClarifaiSearchTerm *searchTerm = [[ClarifaiSearchTerm alloc] initWithSearchItem:image isInput:NO];
  [_app search:@[searchTerm] page:@1 perPage:@20 language:nil completion:^(NSArray<ClarifaiSearchResult *> *outputs, NSError *error) {
    XCTAssert(error == nil);
    [future setResult:@(YES)];
  }];
  [future getResult];
}

- (void)testSearchByConceptNameOutputs {
  CAIFuture *future = [[CAIFuture alloc] init];
  [self testAddInputs];
  ClarifaiConcept *concept1 = [[ClarifaiConcept alloc] initWithConceptName:@"列車"];
  ClarifaiSearchTerm *searchTerm = [[ClarifaiSearchTerm alloc] initWithSearchItem:concept1 isInput:NO];
  [_app search:@[searchTerm] page:@1 perPage:@20 language:@"ja" completion:^(NSArray<ClarifaiSearchResult *> *outputs, NSError *error) {
    XCTAssert(error == nil);
    XCTAssert([outputs count] > 0);
    XCTAssert([outputs[0].mediaURL isEqualToString:@"https://samples.clarifai.com/metro-north.jpg"]);
    XCTAssert(outputs[0].score.doubleValue > 0.5);
    [future setResult:@(YES)];
  }];
  [future getResult];
}

- (void)testSearchByConceptName {
    CAIFuture *future = [[CAIFuture alloc] init];
  [_app searchForConceptsByName:@"d*" andLanguage:@"en" completion:^(NSArray<ClarifaiConcept *> *concepts, NSError *error) {
    XCTAssert(error == nil);
    XCTAssert([concepts count] > 0);
    XCTAssert([concepts[0].conceptName characterAtIndex:0] == 'd');
    [future setResult:@(YES)];
  }];
  [future getResult];
}

- (void)testPredictGeneralModelChinese {
  CAIFuture *future = [[CAIFuture alloc] init];
  // first get the general model.
  [_app getModelByName:@"general-v1.3" completion:^(ClarifaiModel *model, NSError *error) {
    // create input to predict on.
    ClarifaiImage *input = [[ClarifaiImage alloc] initWithURL:@"https://samples.clarifai.com/metro-north.jpg"];
    
    // predict with the general model in Chinese.
    [model predictOnImages:@[input] withLanguage:@"zh" completion:^(NSArray<ClarifaiOutput *> *outputs, NSError *error) {
      for (ClarifaiConcept *concept in outputs[0].concepts) {
        NSLog(@"tag: %@", concept.conceptName);
        NSLog(@"probability: %f", concept.score);
      }
      [future setResult:@(YES)];
    }];
  }];
  
//  CAIFuture *future = [[CAIFuture alloc] init];
//  [_app getModelByName:@"general-v1.3" completion:^(ClarifaiModel *model, NSError *error) {
//    XCTAssert(error == nil);
//    ClarifaiImage *input = [[ClarifaiImage alloc] initWithURL:@"https://samples.clarifai.com/metro-north.jpg"];
//    [model predictOnImages:@[input] withLanguage:@"en" completion:^(NSArray<ClarifaiOutput *> *outputs, NSError *error) {
//      XCTAssert([outputs count] > 0);
//      XCTAssert(outputs[0].concepts[0].score > 0.8);
//      [future setResult:@(YES)];
//    }];
//  }];
  [future getResult];
}

- (void)testSearchByConceptIDInputs {
  CAIFuture *future = [[CAIFuture alloc] init];
  [self testAddInputs];
  ClarifaiConcept *concept1 = [[ClarifaiConcept alloc] initWithConceptID:@"ggod"];
  ClarifaiSearchTerm *searchTerm = [[ClarifaiSearchTerm alloc] initWithSearchItem:concept1 isInput:YES];
  [_app search:@[searchTerm] page:@1 perPage:@20 language:nil completion:^(NSArray<ClarifaiSearchResult *> *inputs, NSError *error) {
    XCTAssert(error == nil);
    XCTAssert([inputs count] > 0);
    XCTAssert([inputs[0].mediaURL isEqualToString:@"http://www.pumapedia.com/wp-content/uploads/2012/10/puma-roca.jpg"]);
    XCTAssert(inputs[0].score.doubleValue > 0.5);
    [future setResult:@(YES)];
  }];
  [future getResult];
}

- (void)testSearchVisuallyByInputIDWithCrop {
  CAIFuture *future = [[CAIFuture alloc] init];
  [self testAddInputs];
  ClarifaiImage *image = [[ClarifaiImage alloc] init];
  image.inputID = _runningImageID;
  image.crop = [[ClarifaiCrop alloc] initWithTop:.2 left:.3 bottom:.7 right:.8];
  ClarifaiSearchTerm *searchTerm = [[ClarifaiSearchTerm alloc] initWithSearchItem:image isInput:YES];
  [_app search:@[searchTerm] page:@1 perPage:@20 language:nil completion:^(NSArray<ClarifaiSearchResult *> *outputs, NSError *error) {
    XCTAssert(error == nil);
    [future setResult:@(YES)];
  }];
  [future getResult];
}

- (void)testSearchInputsByImageURL {
  CAIFuture *future = [[CAIFuture alloc] init];
  ClarifaiImage *image = [[ClarifaiImage alloc] initWithURL:@"http://i.imgur.com/HEoT5xR.png"];
  ClarifaiSearchTerm *searchTerm = [[ClarifaiSearchTerm alloc] initWithSearchItem:image isInput:YES];
  [_app search:@[searchTerm] page:@1 perPage:@20 language:nil completion:^(NSArray<ClarifaiSearchResult *> *outputs, NSError *error) {
    XCTAssert(error == nil);
    [future setResult:@(YES)];
  }];
  [future getResult];
}

- (void)testSearchInputsAndOutputsByConcept {
  CAIFuture *future = [[CAIFuture alloc] init];
  ClarifaiConcept *concept1 = [[ClarifaiConcept alloc] initWithConceptName:@"dogg"];
  ClarifaiConcept *concept2 = [[ClarifaiConcept alloc] initWithConceptName:@"burffet"];
  ClarifaiSearchTerm *searchTerm1 = [[ClarifaiSearchTerm alloc] initWithSearchItem:concept1 isInput:YES];
  ClarifaiSearchTerm *searchTerm2 = [[ClarifaiSearchTerm alloc] initWithSearchItem:concept2 isInput:NO];
  [_app search:@[searchTerm1] page:@1 perPage:@20 language:nil completion:^(NSArray<ClarifaiSearchResult *> *outputs, NSError *error) {
    XCTAssert(error == nil);
    [future setResult:@(YES)];
  }];
  [future getResult];
}

- (void)testGetConcepts {
  CAIFuture *future = [[CAIFuture alloc] init];
  [_app getConceptsOnPage:1 pageSize:30 completion:^(NSArray<ClarifaiConcept *> *concepts, NSError *error) {
    XCTAssert(error == nil);
    [future setResult:@(YES)];
  }];
  [future getResult];
}

- (void)testAddConcepts {
  CAIFuture *future = [[CAIFuture alloc] init];
  NSString *conceptName = [self randomString]; //uses different name on each run (no way to delete free floating concepts).
  [self addConcept:conceptName completion:^(NSArray<ClarifaiConcept *> *concepts, NSError *error) {
    XCTAssert(error == nil);
    [future setResult:@(YES)];
  }];
  [future getResult];
}

- (void)addConcept:(NSString *)conceptName completion:(ClarifaiConceptsCompletion) completion {
  ClarifaiConcept *concept1 = [[ClarifaiConcept alloc] initWithConceptName: conceptName];
  _runningConceptID = concept1.conceptID;
  [_app addConcepts:@[concept1] completion:^(NSArray<ClarifaiConcept *> *concepts, NSError *error) {
    XCTAssert(error == nil);
    XCTAssert([conceptName isEqualToString:concepts[0].conceptID]);
    completion(concepts,error);
  }];
}

- (void)testGetConceptByID {
  CAIFuture *future = [[CAIFuture alloc] init];
  NSString *conceptName = [self randomString];
  __weak ClarifaiApp *app = _app;
  [self addConcept:conceptName completion:^(NSArray<ClarifaiConcept *> *concepts, NSError *error) {
    [app getConcept:_runningConceptID completion:^(ClarifaiConcept *concept, NSError *error) {
      XCTAssert(error == nil);
      XCTAssert([_runningConceptID isEqualToString:concept.conceptID]);
      [future setResult:@(YES)];
    }];
  }];
  [future getResult];
}

- (void)testMergeConceptsToModel {
  CAIFuture *future = [[CAIFuture alloc] init];
  [self testCreateModel];
  ClarifaiConcept *concept = [[ClarifaiConcept alloc] initWithConceptName:@"burf"];
  NSString *modelID = @"burfgerz";
  [_app mergeConcepts:@[concept] forModelWithID:modelID completion:^(ClarifaiModel *model, NSError *error) {
    XCTAssert(error == nil);
    [_app getModelByID:modelID completion:^(ClarifaiModel *model, NSError *error) {
      XCTAssert(error == nil);
      bool burf = NO;
      bool ggod = NO;
      for (ClarifaiConcept *concept in model.concepts) {
        if ([concept.conceptID isEqualToString:@"burf"]) {
          burf = YES;
        } else if ([concept.conceptID isEqualToString:@"ggod"]) {
          ggod = YES;
        }
      }
      XCTAssert(burf);
      XCTAssert(ggod);
      [future setResult:@(YES)];
    }];
  }];
  [future getResult];
}

- (void)testSetConceptsToModel {
  CAIFuture *future = [[CAIFuture alloc] init];
  [self testCreateModel];
  ClarifaiConcept *concept = [[ClarifaiConcept alloc] initWithConceptName:@"burf"];
  NSString *modelID = @"burfgerz";
  [_app setConcepts:@[concept] forModelWithID:modelID completion:^(ClarifaiModel *model, NSError *error) {
    XCTAssert(error == nil);
    [_app getModelByID:modelID completion:^(ClarifaiModel *model, NSError *error) {
      XCTAssert(error == nil);
      bool burf = NO;
      bool otherConcepts = NO; // should have no others after overwrite.
      for (ClarifaiConcept *concept in model.concepts) {
        if ([concept.conceptID isEqualToString:@"burf"]) {
          burf = YES;
        } else {
          otherConcepts = YES;
        }
      }
      XCTAssert(burf);
      XCTAssert(!otherConcepts);
      [future setResult:@(YES)];
    }];
  }];
  [future getResult];
}

- (void)testDeleteConceptsToModel {
  CAIFuture *future = [[CAIFuture alloc] init];
  [self testCreateModel];
  ClarifaiConcept *concept = [[ClarifaiConcept alloc] initWithConceptName:@"ggod"];
  NSString *modelID = @"burfgerz";
  [_app deleteConcepts:@[concept] fromModelWithID:modelID completion:^(ClarifaiModel *model, NSError *error) {
    XCTAssert(error == nil);
    [_app getModelByID:modelID completion:^(ClarifaiModel *model, NSError *error) {
      XCTAssert(error == nil);
      bool ggod = NO;
      bool otherConcepts = NO; // should have no others after delete.
      for (ClarifaiConcept *concept in model.concepts) {
        if ([concept.conceptID isEqualToString:@"ggod"]) {
          ggod = YES;
        } else {
          otherConcepts = YES;
        }
      }
      XCTAssert(!ggod);
      XCTAssert(!otherConcepts);
      [future setResult:@(YES)];
    }];
  }];
  [future getResult];
}

- (void)testCreateModel {
  CAIFuture *future = [[CAIFuture alloc] init];
  NSString *modelName = @"burfgerz";
  [_app deleteModel:modelName completion:^(NSError *error) {
    ClarifaiConcept *concept = [[ClarifaiConcept alloc] initWithConceptName:@"ggod"];
    [_app createModel:@[concept] name:modelName conceptsMutuallyExclusive:NO closedEnvironment:NO completion:^(ClarifaiModel *model, NSError *error) {
      XCTAssert(error == nil);
      XCTAssert([modelName isEqualToString:model.name]);
      [future setResult:@(YES)];
    }];
  }];
  [future getResult];
}

- (void)testGetModelsOnPage {
  CAIFuture *future = [[CAIFuture alloc] init];
  [self testCreateModel];
  [_app getModels:1 resultsPerPage:30 completion:^(NSArray<ClarifaiModel *> *models, NSError *error) {
    XCTAssert(error == nil);
    BOOL foundBurgers = NO;
    for (ClarifaiModel *model in models) {
      if ([model.name isEqualToString:@"burfgerz"]) {
        foundBurgers = YES;
        _runningModelID = model.modelID;
      }
    }
    XCTAssert(foundBurgers);
    [future setResult:@(YES)];
  }];
  
  [future getResult];
}

- (void)testGetModelByID {
  CAIFuture *future = [[CAIFuture alloc] init];
  [self testGetModelsOnPage];
  [_app getModelByID:_runningModelID completion:^(ClarifaiModel *model, NSError *error) {
    XCTAssert(error == nil);
    BOOL foundBurgers = NO;
    if ([model.name isEqualToString:@"burfgerz"]) {
      foundBurgers = YES;
      _runningModelID = model.modelID;
    }
    XCTAssert(foundBurgers);
    [future setResult:@(YES)];
  }];
  
  [future getResult];
}

- (void)testDeleteModelByID {
  CAIFuture *future = [[CAIFuture alloc] init];
  [self testGetModelsOnPage];
  [_app deleteModel:_runningModelID completion:^(NSError *error) {
    XCTAssert(error == nil);
    [_app getModelByID:_runningModelID completion:^(ClarifaiModel *model, NSError *error) {
      //should be error if model was properly deleted.
      XCTAssert(error != nil);
      [future setResult:@(YES)];
    }];
  }];
  
  [future getResult];
}

- (void) pollForModelsWithTimeout:(NSInteger)attempts completion:(ClarifaiRequestCompletion)completion {
  if (attempts > 0) {
    [_app getModels:1 resultsPerPage:30 completion:^(NSArray<ClarifaiModel *> *models, NSError *error) {
      if (error != nil) {
        completion(error);
      } else {
        BOOL privateModelPresent = NO;
        for (ClarifaiModel *model in models) {
          if (![model.appID isKindOfClass:[NSNull class]]) {
            privateModelPresent = YES;
          }
        }
        if (!privateModelPresent) {
          completion(nil); // all private models were deleted.
        } else {
          dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
            [self pollForInputWithTimeout:attempts-1 completion:completion];
          });
        }
      }
    }];
  } else {
    // timed out, all attempts completed.
    NSError *error = [[NSError alloc] initWithDomain:@"com.clarifai.ClarifaiClient" code:(NSInteger)408 userInfo:@{@"description":@"Request timed out. Input still existed after all attempts."}];
    completion(error);
  }
}

- (void)testDeleteAllModels {
  CAIFuture *future = [[CAIFuture alloc] init];
  [self testCreateModel];
  [_app deleteAllModels:^(NSError *error) {
    XCTAssert(error == nil);
    [self pollForModelsWithTimeout:20 completion:^(NSError *error) {
      XCTAssert(error == nil);
      [future setResult:@(YES)];
    }];
  }];
  
  [future getResult];
}

- (void)testDeleteModelsByIDListStrings {
  CAIFuture *future = [[CAIFuture alloc] init];
  [self testGetModelsOnPage];
  [_app deleteModelsByIDList:@[_runningModelID] completion:^(NSError *error) {
    XCTAssert(error == nil);
    [self pollForModelsWithTimeout:20 completion:^(NSError *error) {
      XCTAssert(error == nil);
      [future setResult:@(YES)];
    }];
  }];
  
  [future getResult];
}

- (void)testDeleteModelsByIDListModels {
  CAIFuture *future = [[CAIFuture alloc] init];
  [self testGetModelsOnPage];
  [_app getModelByID:_runningModelID completion:^(ClarifaiModel *model, NSError *error) {
    [_app deleteModelsByIDList:@[model] completion:^(NSError *error) {
      XCTAssert(error == nil);
      [self pollForModelsWithTimeout:20 completion:^(NSError *error) {
        XCTAssert(error == nil);
        [future setResult:@(YES)];
      }];
    }];
  }];
  
  [future getResult];
}

- (void)testGetModelOutputInfo {
  CAIFuture *future = [[CAIFuture alloc] init];
  [self testGetModelsOnPage];
  [_app getOutputInfoForModel:_runningModelID completion:^(ClarifaiModel *model, NSError *error) {
    XCTAssert(error == nil);
    BOOL foundBurgers = NO;
    if ([model.name isEqualToString:@"burfgerz"]) {
      foundBurgers = YES;
    }
    XCTAssert(foundBurgers);
    XCTAssert([model.concepts count] > 0);
    [future setResult:@(YES)];
  }];
  [future getResult];
}

- (void)testTrainBurfgerz {
  CAIFuture *future = [[CAIFuture alloc] init];
  [self testGetModelsOnPage];
  
  [_app getModelByID:_runningModelID completion:^(ClarifaiModel *model, NSError *error) {
    
    XCTAssert(error == nil);
    XCTAssert([model.modelID isEqualToString:_runningModelID]);
    
    [model train:^(ClarifaiModelVersion *version, NSError *error) {
      
      XCTAssert(error == nil);
      XCTAssert(version.statusCode.longValue == (long)21100);
      
      [future setResult:@(YES)];
    }];
  }];
  [future getResult];
}

- (void)testTrainModel {
  CAIFuture *future = [[CAIFuture alloc] init];
  [self testGetModelsOnPage];
  // init concepts and inputs
  ClarifaiConcept *conceptBurf = [[ClarifaiConcept alloc] initWithConceptName:@"burffet"];
  conceptBurf.score = 1.0;
  ClarifaiInput *input1 = [[ClarifaiInput alloc] initWithURL:@"http://www.pumapedia.com/wp-content/uploads/2012/10/puma-roca.jpg" andConcepts:@[conceptBurf]];
  
  ClarifaiConcept *conceptDogg = [[ClarifaiConcept alloc] initWithConceptName:@"dogg"];
  conceptDogg.score = 1.0;
  ClarifaiInput *input2 = [[ClarifaiInput alloc] initWithURL:@"http://www.pumapedia.com/wp-content/uploads/2012/10/puma-roca.jpg" andConcepts:@[conceptDogg]];
  input1.allowDuplicateURLs = YES;
  
  // grab model
  [_app getModelByID:_runningModelID completion:^(ClarifaiModel *model, NSError *error) {
    XCTAssert(error == nil);
    ClarifaiModel *modelToTrain = model;
    // add input to app containing positive example
    [_app addInputs:@[input1,input2] completion:^(NSArray<ClarifaiInput *> *inputs, NSError *error) {
      XCTAssert(error == nil);
      
      // add concept to model
      [_app mergeConcepts:@[conceptBurf] forModelWithID:modelToTrain.modelID completion:^(ClarifaiModel *model, NSError *error) {
        [_app getModelByID:model.modelID completion:^(ClarifaiModel *modell, NSError *error) {
          
          
          XCTAssert(error == nil);
          [NSThread sleepForTimeInterval:1.0];
          // train model
          [modell train:^(ClarifaiModelVersion *modelVersion, NSError *error) {
            XCTAssert(error == nil);
            XCTAssert(modelVersion.statusCode.longValue == (long)21100);
            XCTAssert(modelVersion.statusCode.longValue == modell.version.statusCode.longValue);
            [future setResult:@(YES)];
          }];
        }];
      }];
      
    }];
  }];
  [future getResult];
}

- (void)testPredictColorModel {
  CAIFuture *future = [[CAIFuture alloc] init];
  ClarifaiImage *candelabra2 = [[ClarifaiImage alloc]
                                initWithURL:@"http://d28xhcgddm1buq.cloudfront.net/product-images/candelabras-5-candle-13x-24-3_260.jpg"];
  ClarifaiImage *puma = [[ClarifaiImage alloc]
                         initWithURL:@"http://www.pumapedia.com/wp-content/uploads/2012/10/puma-roca.jpg"];
  
  //change this to search for model by name
  [_app getModelByID:@"eeed0b6733a644cea07cf4c60f87ebb7" completion:^(ClarifaiModel *model, NSError *error) {
    XCTAssert(model != nil);
    [model predictOnImages:@[candelabra2, puma]
                completion:^(NSArray<ClarifaiOutput *> *outputs, NSError *error) {
                  XCTAssert(outputs != nil);
                  [future setResult:@(YES)];
                }];
  }];
  [future getResult];
}

- (void)testPredictTravelModel {
  CAIFuture *future = [[CAIFuture alloc] init];
  ClarifaiImage *candelabra2 = [[ClarifaiImage alloc]
                                initWithURL:@"http://d28xhcgddm1buq.cloudfront.net/product-images/candelabras-5-candle-13x-24-3_260.jpg"];
  ClarifaiImage *puma = [[ClarifaiImage alloc]
                         initWithURL:@"http://www.pumapedia.com/wp-content/uploads/2012/10/puma-roca.jpg"];
  
  //change this to search for model by name
  [_app getModelByID:@"eee28c313d69466f836ab83287a54ed9" completion:^(ClarifaiModel *model, NSError *error) {
    XCTAssert(model != nil);
    [model predictOnImages:@[candelabra2, puma]
                completion:^(NSArray<ClarifaiOutput *> *outputs, NSError *error) {
                  XCTAssert(outputs != nil);
                  [future setResult:@(YES)];
                }];
  }];
  [future getResult];
}

- (void)testPredictFoodModel {
  CAIFuture *future = [[CAIFuture alloc] init];
  ClarifaiImage *candelabra2 = [[ClarifaiImage alloc]
                                initWithURL:@"http://d28xhcgddm1buq.cloudfront.net/product-images/candelabras-5-candle-13x-24-3_260.jpg"];
  ClarifaiImage *puma = [[ClarifaiImage alloc]
                         initWithURL:@"http://www.pumapedia.com/wp-content/uploads/2012/10/puma-roca.jpg"];
  
  //change this to search for model by name
  [_app getModelByID:@"bd367be194cf45149e75f01d59f77ba7" completion:^(ClarifaiModel *model, NSError *error) {
    XCTAssert(model != nil);
    [model predictOnImages:@[candelabra2, puma]
                completion:^(NSArray<ClarifaiOutput *> *outputs, NSError *error) {
                  XCTAssert(outputs != nil);
                  [future setResult:@(YES)];
                }];
  }];
  [future getResult];
}

- (void)testPredictNSFWModel {
  CAIFuture *future = [[CAIFuture alloc] init];
  ClarifaiImage *candelabra2 = [[ClarifaiImage alloc]
                                initWithURL:@"http://d28xhcgddm1buq.cloudfront.net/product-images/candelabras-5-candle-13x-24-3_260.jpg"];
  ClarifaiImage *puma = [[ClarifaiImage alloc]
                         initWithURL:@"http://www.pumapedia.com/wp-content/uploads/2012/10/puma-roca.jpg"];
  
  //change this to search for model by name
  [_app getModelByID:@"e9576d86d2004ed1a38ba0cf39ecb4b1" completion:^(ClarifaiModel *model, NSError *error) {
    XCTAssert(model != nil);
    [model predictOnImages:@[candelabra2, puma]
                completion:^(NSArray<ClarifaiOutput *> *outputs, NSError *error) {
                  XCTAssert(outputs != nil);
                  [future setResult:@(YES)];
                }];
  }];
  [future getResult];
}

- (void)testEmbedModel {
  CAIFuture *future = [[CAIFuture alloc] init];
  ClarifaiImage *candelabra2 = [[ClarifaiImage alloc]
                                initWithURL:@"http://d28xhcgddm1buq.cloudfront.net/product-images/candelabras-5-candle-13x-24-3_260.jpg"];
  ClarifaiImage *puma = [[ClarifaiImage alloc]
                         initWithURL:@"http://www.pumapedia.com/wp-content/uploads/2012/10/puma-roca.jpg"];
  [_app getModelByID:@"bbb5f41425b8468d9b7a554ff10f8581" completion:^(ClarifaiModel *model, NSError *error) {
    XCTAssert(model != nil);
    [model predictOnImages:@[candelabra2, puma]
                completion:^(NSArray<ClarifaiOutput *> *outputs, NSError *error) {
                  XCTAssert(outputs != nil);
                  [future setResult:@(YES)];
                }];
  }];
  [future getResult];
}

- (void)testListVersionsForModel {
  CAIFuture *future = [[CAIFuture alloc] init];
  [self testGetModelsOnPage];
  [_app listVersionsForModel:_runningModelID page:1 resultsPerPage:30 completion:^(NSArray<ClarifaiModelVersion *> *versions, NSError *error) {
    XCTAssert(error == nil);
    _runningVersionID = versions[0].versionID;
    [future setResult:@(YES)];
  }];
  
  [future getResult];
}

- (void)testGetVersionForModel {
  CAIFuture *future = [[CAIFuture alloc] init];
  [self testListVersionsForModel];
  [_app getVersionForModel:_runningModelID versionID:_runningVersionID completion:^(ClarifaiModelVersion *version, NSError *error) {
    XCTAssert(error == nil);
     XCTAssert([version.versionID isEqualToString:_runningVersionID]);
    [future setResult:@(YES)];
  }];
  
  [future getResult];
}

- (void)testDeleteVersionForModel {
  CAIFuture *future = [[CAIFuture alloc] init];
  [self testListVersionsForModel];
  [_app deleteVersionForModel:_runningModelID versionID:_runningVersionID completion:^(NSError *error) {
    XCTAssert(error == nil);
    [_app getVersionForModel:_runningModelID versionID:_runningVersionID completion:^(ClarifaiModelVersion *version, NSError *error) {
      XCTAssert(error != nil);
      [future setResult:@(YES)];
    }];
  }];
  
  [future getResult];
}

- (void)testListTrainingInputsForModel {
  CAIFuture *future = [[CAIFuture alloc] init];
  [self testGetModelsOnPage];
  [_app listTrainingInputsForModel:_runningModelID page:1 resultsPerPage:30 completion:^(NSArray<ClarifaiInput *> *inputs, NSError *error) {
    XCTAssert(error == nil);
    XCTAssert([inputs count] > 0);
    [future setResult:@(YES)];
  }];
  
  [future getResult];
}

- (void)testListTrainingInputsForModelVersion {
  CAIFuture *future = [[CAIFuture alloc] init];
  [self testListVersionsForModel];
  
  [_app listTrainingInputsForModel:_runningModelID version:_runningVersionID page:1 resultsPerPage:30 completion:^(NSArray<ClarifaiInput *> *inputs, NSError *error) {
    XCTAssert(error == nil);
    XCTAssert([inputs count] > 0);
    [future setResult:@(YES)];
  }];
  
  [future getResult];
}

- (void)testPredictGeneralModel {
  CAIFuture *future = [[CAIFuture alloc] init];
  ClarifaiImage *image = [[ClarifaiImage alloc] initWithURL:@"http://i.imgur.com/rbJgWn1.jpg"];
  [_app getModelByName:@"general-v1.3" completion:^(ClarifaiModel *model, NSError *error) {
    XCTAssert(error == nil);
    [model predictOnImages:@[image] completion:^(NSArray<ClarifaiSearchResult *> *outputs, NSError *error) {
      XCTAssert(error == nil);
      XCTAssert([outputs count] > 0);
      [future setResult:@(YES)];
    }];
  }];
  [future getResult];
}

- (void)testSearchModelsByName {
  CAIFuture *future = [[CAIFuture alloc] init];
  [self testGetModelsOnPage];
  
  [_app searchForModelByName:@"burfgerz" modelType:ClarifaiModelTypeConcept completion:^(NSArray<ClarifaiModel *> *models, NSError *error) {
    XCTAssert(error == nil);
    XCTAssert([models count] > 0);
    [future setResult:@(YES)];
  }];
  
  [future getResult];
}

- (NSString *)randomString {
  NSString *alphabet  = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXZY0123456789";
  NSMutableString *s = [NSMutableString stringWithCapacity:20];
  for (NSUInteger i = 0U; i < 20; i++) {
    u_int32_t r = arc4random() % [alphabet length];
    unichar c = [alphabet characterAtIndex:r];
    [s appendFormat:@"%C", c];
  }
  return s;
}

- (void)addConcept:(NSString *)conceptName {
  CAIFuture *future = [[CAIFuture alloc] init];
  ClarifaiConcept *concept1 = [[ClarifaiConcept alloc] initWithConceptName: conceptName];
  _runningConceptID = concept1.conceptID;
  [_app addConcepts:@[concept1] completion:^(NSArray<ClarifaiConcept *> *concepts, NSError *error) {
    XCTAssert(error == nil);
    XCTAssert([conceptName isEqualToString:concepts[0].conceptID]);
    [future setResult:@(YES)];
  }];
}

@end









