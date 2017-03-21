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
  
  // delete all inputs and models before starting each test.
  CAIFuture *future = [[CAIFuture alloc] init];
  [_app deleteAllInputs:^(NSError *error) {
    [self pollForInputWithTimeout:40 completion:^(NSError *error) {
      [_app deleteAllModels:^(NSError *error) {
        [self pollForModelsWithTimeout:40 completion:^(NSError *error) {
          [future setResult:@(YES)];
        }];
      }];
    }];
  }];
  [future getResult];
}

#pragma mark INPUTS TESTS

- (void)testAddInputs {
  CAIFuture *future = [[CAIFuture alloc] init];
  
  //create first image and concept.
  ClarifaiConcept *concept1 = [[ClarifaiConcept alloc] initWithConceptName:@"dogg"];
  concept1.score = 0;
  ClarifaiCrop *crop = [[ClarifaiCrop alloc] initWithTop:0.2 left:0.3 bottom:0.7 right:0.8];
  ClarifaiImage *img1 = [[ClarifaiImage alloc] initWithURL:@"https://samples.clarifai.com/metro-north.jpg" andConcepts:@[concept1]];
  img1.location = [[ClarifaiLocation alloc] initWithLatitude:45.6 longitude:43.2];
  img1.allowDuplicateURLs = YES;
  
  //create second image and concept.
  ClarifaiConcept *concept2 = [[ClarifaiConcept alloc] initWithConceptName:@"ggod"];
  concept2.score = 1;
  ClarifaiImage *img2 = [[ClarifaiImage alloc] initWithURL:@"https://samples.clarifai.com/metro-north.jpg" crop:crop andConcepts:@[concept2]];
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
    XCTAssert(input1.location.latitude == 45.6);
    
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

- (void)testUpdateGeoPointForInput {
  CAIFuture *future = [[CAIFuture alloc] init];
  [self testAddInputs];
  ClarifaiLocation *location = [[ClarifaiLocation alloc] initWithLatitude:45 longitude:56];
  [_app updateGeoPoint:location forInputWithID:_runningImageID completion:^(ClarifaiInput *input, NSError *error) {
    XCTAssert(error == nil);
    XCTAssert(input.location != nil);
    XCTAssert(input.location.latitude == 45);
    XCTAssert(input.location.longitude == 56);
    [future setResult:@(YES)];
  }];
  [future getResult];
}

#pragma mark UPDATE CONCEPTS FOR INPUTS TESTS

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

#pragma mark CONCEPTS TESTS

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

#pragma mark UPDATE CONCEPTS FOR MODELS TESTS

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

#pragma mark MODELS TESTS

- (void)testCreateModel {
  CAIFuture *future = [[CAIFuture alloc] init];
  [self testAddInputs];
  [NSThread sleepForTimeInterval:1.0];
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

- (void)testTrainBurfgerz {
  CAIFuture *future = [[CAIFuture alloc] init];
  [self testGetModelsOnPage];
  
  [_app getModelByID:_runningModelID completion:^(ClarifaiModel *model, NSError *error) {
    
    XCTAssert(error == nil);
    XCTAssert([model.modelID isEqualToString:_runningModelID]);
    [NSThread sleepForTimeInterval:5.0];
    [model train:^(ClarifaiModelVersion *version, NSError *error) {
      
      XCTAssert(error == nil);
      XCTAssert(version.statusCode.longValue == (long)21100);
      
      ClarifaiImage *image = [[ClarifaiImage alloc] initWithURL:@"http://bnbjoint.com/wp-content/uploads/2015/04/Thunder_Road_full-300dpi.jpg"];
      [model predictOnImages:@[image] completion:^(NSArray<ClarifaiOutput *> *outputs, NSError *error) {
        XCTAssert(error == nil);
        XCTAssert([outputs count] > 0);
        [future setResult:@(YES)];
      }];
    }];
  }];
  [future getResult];
}

- (void)testPredictBurfgerz {
  CAIFuture *future = [[CAIFuture alloc] init];
  [self testCreateModel];
  
  [_app getModelByName:@"burfgerz" completion:^(ClarifaiModel *model, NSError *error) {
    
    XCTAssert(error == nil);
    [NSThread sleepForTimeInterval:5.0];
    [model train:^(ClarifaiModelVersion *version, NSError *error) {
      
      XCTAssert(error == nil);
      XCTAssert(version.statusCode.longValue == (long)21100);
      
      UIImage *dope = [UIImage imageNamed:@"geth.jpg"];
      
      ClarifaiImage *image = [[ClarifaiImage alloc] initWithImage:dope];
      
      [model predictOnImages:@[image] completion:^(NSArray<ClarifaiOutput *> *outputs, NSError *error) {
        ClarifaiOutput *output = outputs[0];
        XCTAssert(error == nil);
        XCTAssert([outputs count] > 0);
        [future setResult:@(YES)];
      }];
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
    [self pollForModelsWithTimeout:40 completion:^(NSError *error) {
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
    [self pollForModelsWithTimeout:40 completion:^(NSError *error) {
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
      [self pollForModelsWithTimeout:40 completion:^(NSError *error) {
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

#pragma mark MODEL VERSION TESTS

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
  // Check back on this.
//  CAIFuture *future = [[CAIFuture alloc] init];
//  [self testListVersionsForModel];
//  [_app deleteVersionForModel:_runningModelID versionID:_runningVersionID completion:^(NSError *error) {
//    XCTAssert(error == nil);
//    [_app getVersionForModel:_runningModelID versionID:_runningVersionID completion:^(ClarifaiModelVersion *version, NSError *error) {
//      XCTAssert(error != nil);
//      [future setResult:@(YES)];
//    }];
//  }];
//  
//  [future getResult];
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

#pragma mark PUBLIC MODEL PREDICT TESTS

- (void)testPredictColorModel {
  CAIFuture *future = [[CAIFuture alloc] init];
  ClarifaiImage *candelabra2 = [[ClarifaiImage alloc]
                                initWithURL:@"http://d28xhcgddm1buq.cloudfront.net/product-images/candelabras-5-candle-13x-24-3_260.jpg"];
  ClarifaiImage *puma = [[ClarifaiImage alloc]
                         initWithURL:@"https://samples.clarifai.com/metro-north.jpg"];
  
  //change this to search for model by name
  [_app getModelByID:@"eeed0b6733a644cea07cf4c60f87ebb7" completion:^(ClarifaiModel *model, NSError *error) {
    XCTAssert(model != nil);
    [model predictOnImages:@[candelabra2, puma]
                completion:^(NSArray<ClarifaiOutput *> *outputs, NSError *error) {
                  XCTAssert(outputs != nil);
                  XCTAssert([outputs count] > 0);
                  XCTAssert([outputs[0].colors count] > 0);
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
                         initWithURL:@"https://samples.clarifai.com/metro-north.jpg"];
  
  //change this to search for model by name
  [_app getModelByID:@"eee28c313d69466f836ab83287a54ed9" completion:^(ClarifaiModel *model, NSError *error) {
    XCTAssert(model != nil);
    [model predictOnImages:@[candelabra2, puma]
                completion:^(NSArray<ClarifaiOutput *> *outputs, NSError *error) {
                  XCTAssert(outputs != nil);
                  XCTAssert([outputs count] > 0);
                  XCTAssert([outputs[0].concepts count] > 0);
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
                         initWithURL:@"https://samples.clarifai.com/metro-north.jpg"];
  
  //change this to search for model by name
  [_app getModelByID:@"bd367be194cf45149e75f01d59f77ba7" completion:^(ClarifaiModel *model, NSError *error) {
    XCTAssert(model != nil);
    [model predictOnImages:@[candelabra2, puma]
                completion:^(NSArray<ClarifaiOutput *> *outputs, NSError *error) {
                  XCTAssert(outputs != nil);
                  XCTAssert([outputs count] > 0);
                  XCTAssert([outputs[0].concepts count] > 0);
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
                         initWithURL:@"https://samples.clarifai.com/metro-north.jpg"];
  
  //change this to search for model by name
  [_app getModelByID:@"e9576d86d2004ed1a38ba0cf39ecb4b1" completion:^(ClarifaiModel *model, NSError *error) {
    XCTAssert(model != nil);
    [model predictOnImages:@[candelabra2, puma]
                completion:^(NSArray<ClarifaiOutput *> *outputs, NSError *error) {
                  XCTAssert(outputs != nil);
                  XCTAssert([outputs count] > 0);
                  XCTAssert([outputs[0].concepts count] > 0);
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
                         initWithURL:@"https://samples.clarifai.com/metro-north.jpg"];
  [_app getModelByID:@"bbb5f41425b8468d9b7a554ff10f8581" completion:^(ClarifaiModel *model, NSError *error) {
    XCTAssert(model != nil);
    [model predictOnImages:@[candelabra2, puma]
                completion:^(NSArray<ClarifaiOutput *> *outputs, NSError *error) {
                  XCTAssert([outputs count] > 0);
                  XCTAssert(outputs[0].embedding != nil);
                  [future setResult:@(YES)];
                }];
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

- (void)testPredictGeneralModelChinese {
  CAIFuture *future = [[CAIFuture alloc] init];
  // first get the general model.
  [_app getModelByName:@"general-v1.3" completion:^(ClarifaiModel *model, NSError *error) {
    // create input to predict on.
    ClarifaiImage *input = [[ClarifaiImage alloc] initWithURL:@"https://samples.clarifai.com/metro-north.jpg"];
    
    // predict with the general model in Chinese.
    [model predictOnImages:@[input] withLanguage:@"zh" completion:^(NSArray<ClarifaiOutput *> *outputs, NSError *error) {
      XCTAssert(error == nil);
      XCTAssert([outputs count] > 0);
      [future setResult:@(YES)];
    }];
  }];
  [future getResult];
}

- (void)testApparelModel {
  CAIFuture *future = [[CAIFuture alloc] init];
  ClarifaiImage *image = [[ClarifaiImage alloc] initWithURL:@"http://www.whrl.org/wp-content/uploads/2014/03/three-women.jpg"];
  [_app getModelByID:@"e0be3b9d6a454f0493ac3a30784001ff" completion:^(ClarifaiModel *model, NSError *error) {
    XCTAssert(error == nil);
    [model predictOnImages:@[image] completion:^(NSArray<ClarifaiSearchResult *> *outputs, NSError *error) {
      XCTAssert(error == nil);
      XCTAssert([outputs count] > 0);
      XCTAssert([outputs[0].concepts count] > 0);
//      for (ClarifaiConcept *concept in outputs[0].concepts) {
//        NSLog(@"%@",concept.conceptName);
//      }
      [future setResult:@(YES)];
    }];
  }];
  [future getResult];
}

- (void)testPredictFaceModel {
  CAIFuture *future = [[CAIFuture alloc] init];
  ClarifaiImage *image = [[ClarifaiImage alloc] initWithURL:@"http://www.whrl.org/wp-content/uploads/2014/03/three-women.jpg"];
  [_app getModelByID:@"a403429f2ddf4b49b307e318f00e528b" completion:^(ClarifaiModel *model, NSError *error) {
    XCTAssert(error == nil);
    [model predictOnImages:@[image] completion:^(NSArray<ClarifaiSearchResult *> *outputs, NSError *error) {
      
      XCTAssert(error == nil);
      XCTAssert([outputs count] > 0);
      XCTAssert([outputs[0] isKindOfClass:[ClarifaiOutputFace class]]);
      for (ClarifaiOutputRegion *box in ((ClarifaiOutputFace *)outputs[0]).faces) {
        XCTAssert(box.top > 0.0 || box.left > 0.0 || box.bottom > 0.0 || box.right > 0.0);
//        NSLog(@"boundingBox: %f, %f, %f, %f", box.top, box.left, box.bottom, box.right);
      }
      [future setResult:@(YES)];
    }];
  }];
  [future getResult];
}

- (void)testPredictFocusModel {
  CAIFuture *future = [[CAIFuture alloc] init];
  ClarifaiImage *image = [[ClarifaiImage alloc] initWithURL:@"http://www.whrl.org/wp-content/uploads/2014/03/three-women.jpg"];
  [_app getModelByID:@"c2cf7cecd8a6427da375b9f35fcd2381" completion:^(ClarifaiModel *model, NSError *error) {
    XCTAssert(error == nil);
    [model predictOnImages:@[image] completion:^(NSArray<ClarifaiSearchResult *> *outputs, NSError *error) {
      
      XCTAssert(error == nil);
      XCTAssert([outputs count] > 0);
      XCTAssert([outputs[0] isKindOfClass:[ClarifaiOutputFocus class]]);
      XCTAssert(((ClarifaiOutputFocus *)outputs[0]).focusDensity > 0.0);
      for (ClarifaiOutputRegion *box in ((ClarifaiOutputFocus *)outputs[0]).focusRegions) {
        XCTAssert(box.top > 0.0 || box.left > 0.0 || box.bottom > 0.0 || box.right > 0.0);
        XCTAssert(box.focusDensity > 0.0);
//        NSLog(@"boundingBox: %f, %f, %f, %f", box.top, box.left, box.bottom, box.right);
//        NSLog(@"focus: %f", box.focusDensity);
      }
      [future setResult:@(YES)];
    }];
  }];
  [future getResult];
}

- (void)testPredictLogoModel {
  CAIFuture *future = [[CAIFuture alloc] init];
  ClarifaiImage *image = [[ClarifaiImage alloc] initWithURL:@"https://s-media-cache-ak0.pinimg.com/736x/d6/1b/b2/d61bb21ca2cbe9b24259b24852b24eba.jpg"];
  [_app getModelByID:@"c443119bf2ed4da98487520d01a0b1e3" completion:^(ClarifaiModel *model, NSError *error) {
    XCTAssert(error == nil);
    [model predictOnImages:@[image] completion:^(NSArray<ClarifaiSearchResult *> *outputs, NSError *error) {
      
      XCTAssert(error == nil);
      XCTAssert([outputs count] > 0);
      XCTAssert([outputs[0] isKindOfClass:[ClarifaiOutputLogo class]]);
      for (ClarifaiOutputRegion *box in ((ClarifaiOutputLogo *)outputs[0]).logos) {
        XCTAssert(box.top > 0.0 || box.left > 0.0 || box.bottom > 0.0 || box.right > 0.0);
        XCTAssert([box.concepts count] > 0);
//        NSLog(@"boundingBox: %f, %f, %f, %f", box.top, box.left, box.bottom, box.right);
//        NSLog(@"logo: %@", box.concepts[0].conceptName);
      }
      [future setResult:@(YES)];
    }];
  }];
  [future getResult];
}

#pragma mark SEARCH TESTS

- (void)testSearchInputsByID {
  CAIFuture *future = [[CAIFuture alloc] init];
  [self testAddInputs];
  
  ClarifaiSearchTerm *term = [ClarifaiSearchTerm searchInputsWithInputID:_runningImageID];
  
  [_app search:@[term] page:@1 perPage:@20 language:@"en" completion:^(NSArray<ClarifaiSearchResult *> *results, NSError *error) {
    XCTAssert(error == nil);
    XCTAssert([results count] > 0);
    [future setResult:@(YES)];
  }];
  [future getResult];
}

- (void)testSearchInputsByURL {
  CAIFuture *future = [[CAIFuture alloc] init];
  
  [self testAddInputs];
  
  ClarifaiSearchTerm *term = [ClarifaiSearchTerm searchInputsWithImageURL:@"https://samples.clarifai.com/metro-north.jpg"];
  
  [_app search:@[term] page:@1 perPage:@20 language:@"en" completion:^(NSArray<ClarifaiSearchResult *> *results, NSError *error) {
    XCTAssert(error == nil);
    XCTAssert([results count] > 0);
    [future setResult:@(YES)];
  }];
  [future getResult];
}

- (void)testSearchInputsByConcept {
  CAIFuture *future = [[CAIFuture alloc] init];
  
  [self testAddInputs];
  
  ClarifaiConcept *concept = [[ClarifaiConcept alloc] initWithConceptName:@"ggod"];
  ClarifaiSearchTerm *term = [ClarifaiSearchTerm searchInputsByConcept:concept];
  
  [_app search:@[term] page:@1 perPage:@20 language:@"en" completion:^(NSArray<ClarifaiSearchResult *> *results, NSError *error) {
    XCTAssert(error == nil);
    XCTAssert([results count] > 0);
    [future setResult:@(YES)];
  }];
  [future getResult];
}

- (void)testSearchInputsByGeoBox {
  CAIFuture *future = [[CAIFuture alloc] init];
  
  [self testAddInputs];
  
  ClarifaiLocation *startLoc = [[ClarifaiLocation alloc] initWithLatitude:50 longitude:58];
  ClarifaiLocation *endLoc = [[ClarifaiLocation alloc] initWithLatitude:32 longitude:-30];
  ClarifaiGeo *geoBox = [[ClarifaiGeo alloc] initWithGeoBoxFromStartLocation:startLoc toEndLocation:endLoc];
  
  ClarifaiSearchTerm *term = [ClarifaiSearchTerm searchInputsWithGeoFilter:geoBox];
  
  [_app search:@[term] page:@1 perPage:@20 language:@"en" completion:^(NSArray<ClarifaiSearchResult *> *results, NSError *error) {
    XCTAssert(error == nil);
    XCTAssert([results count] > 0);
    XCTAssert([results[0].concepts[0].conceptName isEqualToString:@"dogg"]);
    [future setResult:@(YES)];
  }];
  [future getResult];
}

- (void)testSearchInputsByGeoPointRadiusDefault {
  CAIFuture *future = [[CAIFuture alloc] init];
  
  [self testAddInputs];
  
  ClarifaiLocation *loc = [[ClarifaiLocation alloc] initWithLatitude:45.6 longitude:43.1];
  ClarifaiGeo *geoFilter = [[ClarifaiGeo alloc] initWithLocation:loc andRadius:100.0];
  ClarifaiSearchTerm *term = [ClarifaiSearchTerm searchInputsWithGeoFilter:geoFilter];
  
  [_app search:@[term] page:@1 perPage:@20 language:@"en" completion:^(NSArray<ClarifaiSearchResult *> *results, NSError *error) {
    XCTAssert(error == nil);
    XCTAssert([results count] > 0);
    XCTAssert([results[0].concepts[0].conceptName isEqualToString:@"dogg"]);
    [future setResult:@(YES)];
  }];
  [future getResult];
}

- (void)testSearchInputsByGeoPointRadiusKilos {
  CAIFuture *future = [[CAIFuture alloc] init];
  
  [self testAddInputs];
  
  ClarifaiLocation *loc = [[ClarifaiLocation alloc] initWithLatitude:45.5 longitude:43.1];
  ClarifaiGeo *geoFilterKilos = [[ClarifaiGeo alloc] initWithLocation:loc radius:100.0 andRadiusUnit:ClarifaiRadiusUnitKilometers];
  ClarifaiSearchTerm *term = [ClarifaiSearchTerm searchInputsWithGeoFilter:geoFilterKilos];
  
  [_app search:@[term] page:@1 perPage:@20 language:@"en" completion:^(NSArray<ClarifaiSearchResult *> *results, NSError *error) {
    XCTAssert(error == nil);
    XCTAssert([results count] > 0);
    XCTAssert([results[0].concepts[0].conceptName isEqualToString:@"dogg"]);
    [future setResult:@(YES)];
  }];
  [future getResult];
}

- (void)testSearchInputsByGeoFilterAndConcept {
  CAIFuture *future = [[CAIFuture alloc] init];
  
  [self testAddInputs];
  
  ClarifaiLocation *loc = [[ClarifaiLocation alloc] initWithLatitude:45.5 longitude:43.2];
  ClarifaiGeo *geoFilter = [[ClarifaiGeo alloc] initWithLocation:loc andRadius:100.0];
  ClarifaiSearchTerm *termGeo = [ClarifaiSearchTerm searchInputsWithGeoFilter:geoFilter];
  
  ClarifaiConcept *concept = [[ClarifaiConcept alloc] initWithConceptName:@"dogg"];
  concept.score = 0;
  ClarifaiSearchTerm *termConcept = [ClarifaiSearchTerm searchInputsByConcept:concept];
  
  [_app search:@[termGeo,termConcept] page:@1 perPage:@20 language:@"en" completion:^(NSArray<ClarifaiSearchResult *> *results, NSError *error) {
    XCTAssert(error == nil);
    XCTAssert([results count] > 0);
    XCTAssert([results[0].concepts[0].conceptName isEqualToString:@"dogg"]);
    [future setResult:@(YES)];
  }];
  [future getResult];
}

- (void)testSearchInputsByMetaData {
  CAIFuture *future = [[CAIFuture alloc] init];
  
  [self testAddInputs];
  
  ClarifaiSearchTerm *term = [ClarifaiSearchTerm searchInputsWithMetadata:@{@"metagurz":@"burf!"}];
  
  [_app search:@[term] page:@1 perPage:@20 language:@"en" completion:^(NSArray<ClarifaiSearchResult *> *results, NSError *error) {
    XCTAssert(error == nil);
    XCTAssert([results count] > 0);
    XCTAssert([results[0].concepts[0].conceptName isEqualToString:@"ggod"]);
    [future setResult:@(YES)];
  }];
  [future getResult];
}

- (void)testSearchOutputsByID {
  CAIFuture *future = [[CAIFuture alloc] init];
  
  [self testAddInputs];
  
  [self pollUntilInputsProcessed:30 completion:^(NSError *error) {
    ClarifaiSearchTerm *term = [ClarifaiSearchTerm searchVisuallyWithInputID:_runningImageID];
    [_app search:@[term] page:@1 perPage:@20 language:@"en" completion:^(NSArray<ClarifaiSearchResult *> *results, NSError *error) {
      XCTAssert(error == nil);
      XCTAssert([results count] > 0);
      [future setResult:@(YES)];
    }];
  }];
  [future getResult];
}

- (void)testSearchOutputsByURL {
  CAIFuture *future = [[CAIFuture alloc] init];
  
  [self testAddInputs];
  
  [self pollUntilInputsProcessed:30 completion:^(NSError *error) {
    
    ClarifaiSearchTerm *term = [ClarifaiSearchTerm searchVisuallyWithImageURL:@"https://samples.clarifai.com/metro-north.jpg"];

    [_app search:@[term] page:@1 perPage:@20 language:@"en" completion:^(NSArray<ClarifaiSearchResult *> *results, NSError *error) {
      XCTAssert(error == nil);
      XCTAssert([results count] > 0);
      [future setResult:@(YES)];
    }];
  }];
  [future getResult];
}

- (void)testSearchOutputsByURLWithCrop {
  CAIFuture *future = [[CAIFuture alloc] init];
  
  [self testAddInputs];
  
  [self pollUntilInputsProcessed:20 completion:^(NSError *error) {
    ClarifaiCrop *crop = [[ClarifaiCrop alloc] initWithTop:0.2 left:0.2 bottom:0.8 right:0.8];
    
    ClarifaiSearchTerm *term1 = [ClarifaiSearchTerm searchVisuallyWithImageURL:@"https://samples.clarifai.com/metro-north.jpg" andCrop:crop];
    
    ClarifaiSearchTerm *term2 = [[ClarifaiSearchTerm searchVisuallyWithImageURL:@"https://samples.clarifai.com/metro-north.jpg"] addImageCrop:crop];
    
    [_app search:@[term1, term2] page:@1 perPage:@20 language:@"en" completion:^(NSArray<ClarifaiSearchResult *> *results, NSError *error) {
      XCTAssert(error == nil);
      XCTAssert([results count] > 0);
      [future setResult:@(YES)];
    }];
  }];
  [future getResult];
}

- (void)testSearchOutputsByImageData {
  CAIFuture *future = [[CAIFuture alloc] init];
  
  [self testAddInputs];
  
  [self pollUntilInputsProcessed:20 completion:^(NSError *error) {
    UIImage *image = [UIImage imageNamed:@"geth.jpg"];
    NSData *imageData = UIImageJPEGRepresentation(image, 0.4);
    
    ClarifaiSearchTerm *term = [ClarifaiSearchTerm searchVisuallyWithImageData:imageData];
    
    [_app search:@[term] page:@1 perPage:@20 language:@"en" completion:^(NSArray<ClarifaiSearchResult *> *results, NSError *error) {
      XCTAssert(error == nil);
      XCTAssert([results count] > 0);
      [future setResult:@(YES)];
    }];
  }];
  [future getResult];
}

- (void)testSearchOutputsByConcepts {
  CAIFuture *future = [[CAIFuture alloc] init];
  
  [self testTrainBurfgerz];
  
  [self pollUntilInputsProcessed:20 completion:^(NSError *error) {
    ClarifaiConcept *conceptFromGeneralModel = [[ClarifaiConcept alloc] initWithConceptName:@"fast"];
    ClarifaiConcept *conceptFromTrainedCustomModel = [[ClarifaiConcept alloc] initWithConceptName:@"ggod"];
    
    ClarifaiSearchTerm *term1 = [ClarifaiSearchTerm searchByPredictedConcept:conceptFromGeneralModel];
    ClarifaiSearchTerm *term2 = [ClarifaiSearchTerm searchByPredictedConcept:conceptFromTrainedCustomModel];
 
    [_app search:@[term1, term2] page:@1 perPage:@20 language:@"en" completion:^(NSArray<ClarifaiSearchResult *> *results, NSError *error) {
      XCTAssert(error == nil);
      XCTAssert([results count] > 0);
      [future setResult:@(YES)];
    }];
  }];
  [future getResult];
}

- (void)testSearchWithoutPaginationOrLanguage {
  CAIFuture *future = [[CAIFuture alloc] init];
  
  [self testAddInputs];
  
  [self pollUntilInputsProcessed:30 completion:^(NSError *error) {
    XCTAssert(error == nil);
    ClarifaiSearchTerm *term = [ClarifaiSearchTerm searchVisuallyWithImageURL:@"https://samples.clarifai.com/metro-north.jpg"];
    
    [_app search:@[term] completion:^(NSArray<ClarifaiSearchResult *> *results, NSError *error) {
      XCTAssert(error == nil);
      XCTAssert([results count] > 0);
      [future setResult:@(YES)];
    }];
  }];
  [future getResult];
}

- (void)testSearchWithoutLanguage {
  CAIFuture *future = [[CAIFuture alloc] init];
  
  [self testAddInputs];
  
  [self pollUntilInputsProcessed:30 completion:^(NSError *error) {
    
    ClarifaiSearchTerm *term = [ClarifaiSearchTerm searchVisuallyWithImageURL:@"https://samples.clarifai.com/metro-north.jpg"];
    
    [_app search:@[term] page:@1 perPage:@20 completion:^(NSArray<ClarifaiSearchResult *> *results, NSError *error) {
      XCTAssert(error == nil);
      XCTAssert([results count] > 0);
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

- (void)testSearchWithMetadata {
  CAIFuture *future = [[CAIFuture alloc] init];
  [self testAddInputs];
  [_app searchByMetadata:@{@"metagurz":@"burf!"} page:@1 perPage:@20 completion:^(NSArray<ClarifaiSearchResult *> *results, NSError *error) {
    XCTAssert([results[0].metadata[@"metagurz"] isEqualToString:@"burf!"]);
    [future setResult:@(YES)];
  }];
  
  [future getResult];
}

- (void)testSearchDepracated {
  CAIFuture *future = [[CAIFuture alloc] init];
  [self testAddInputs];
  
  ClarifaiImage *input = [[ClarifaiImage alloc] initWithURL:@"https://samples.clarifai.com/metro-north.jpg"];
  ClarifaiSearchTerm *term = [[ClarifaiSearchTerm alloc] initWithSearchItem:input isInput:NO];
  
  [_app search:@[term] completion:^(NSArray<ClarifaiSearchResult *> *results, NSError *error) {
    XCTAssert(error == nil);
    XCTAssert([results count] > 0);
    [future setResult:@(YES)];
  }];
  
  [future getResult];
}

#pragma mark LATENCY TESTS

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

#pragma mark HELPERS

- (void) pollUntilInputsProcessed:(NSInteger)attempts completion:(ClarifaiRequestCompletion)completion {
  if (attempts > 0) {
    [_app getInputsStatus:^(int numProcessed, int numToProcess, int errors, NSError *error) {
      if (numToProcess > 0 && error == nil) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
          [self pollForInputWithTimeout:attempts-1 completion:completion];
        });
      } else if (numToProcess == 0 && error == nil) {
        completion(nil);
      } else {
        NSError *error = [[NSError alloc] initWithDomain:@"com.clarifai.ClarifaiClient" code:(NSInteger)408 userInfo:@{@"description":@"Polling Failed with error."}];
        completion(error);
      }
    }];
  } else {
    // timed out, all attempts completed.
    NSError *error = [[NSError alloc] initWithDomain:@"com.clarifai.ClarifaiClient" code:(NSInteger)408 userInfo:@{@"description":@"Request timed out. Inputs still not processed after all attempts."}];
    completion(error);
  }
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

@end









