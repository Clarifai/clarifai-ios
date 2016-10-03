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
  _conCount = 0;
}

- (void)testSearchWithImageData {
  CAIFuture *future = [[CAIFuture alloc] init];
  ClarifaiImage *image = [[ClarifaiImage alloc] initWithImage:[UIImage imageNamed:@"geth.jpg"]];
  ClarifaiSearchTerm *searchTerm = [[ClarifaiSearchTerm alloc] initWithSearchItem:image isInput:NO];
  [_app search:@[searchTerm] page:@1 perPage:@20 completion:^(NSArray<ClarifaiSearchResult *> *results, NSError *error) {
    NSLog(@"results: %@", results);
    [future setResult:@(YES)];
  }];
  [future getResult];
}

- (void)testAddInputsCreateModel {
  CAIFuture *future = [[CAIFuture alloc] init];
  ClarifaiImage *candelabra = [[ClarifaiImage alloc] initWithURL:@"http://i.imgur.com/rbJgWn1.jpg"
                                                     andConcepts:@[@"test_candelabra"]];
  ClarifaiImage *menorah = [[ClarifaiImage alloc] initWithURL:@"http://i.imgur.com/2TgEzZ9.jpg"
                                                  andConcepts:@[@"test_menorah"]];
  
  
  __weak ClarifaiApp *app = _app;
  [app addInputs:@[candelabra, menorah] completion:^(NSArray<ClarifaiInput *> *inputs, NSError *error) {
    assert(inputs != nil);
    [app createModel:@[@"test_candelabra", @"test_menorah"]
                name:@"candelabra"
conceptsMutuallyExclusive:NO
   closedEnvironment:NO
          completion:^(ClarifaiModel *model, NSError *error) {
            assert(model != nil);
            _runningModelID = model.modelID;
            [model train:^(ClarifaiModel *model, NSError *error) {
              assert(model != nil);
              [future setResult:@(YES)];
            }];
          }];
  }];
  [future getResult];
}

- (void)testPredictCandelabraCustomModel {
  CAIFuture *future = [[CAIFuture alloc] init];
  ClarifaiImage *candelabra2 = [[ClarifaiImage alloc]
                                initWithURL:@"http://d28xhcgddm1buq.cloudfront.net/product-images/candelabras-5-candle-13x-24-3_260.jpg"];
  ClarifaiImage *puma = [[ClarifaiImage alloc]
                         initWithURL:@"http://www.pumapedia.com/wp-content/uploads/2012/10/puma-roca.jpg"];
  
  //change this to search for model by name
  [_app getModelByID:@"acbaee6284e94d8882267b1db4d2aa89" completion:^(ClarifaiModel *model, NSError *error) {
    assert(model != nil);
    [model predictOnImages:@[candelabra2, puma]
                completion:^(NSArray<ClarifaiSearchResult *> *outputs, NSError *error) {
                  XCTAssert(outputs != nil);
                  [future setResult:@(YES)];
                }];
  }];
  [future getResult];
}

- (void)testAddInputs {
  CAIFuture *future = [[CAIFuture alloc] init];
  ClarifaiImage *img = [[ClarifaiImage alloc] initWithURL:@"https://samples.clarifai.com/metro-north.jpg"];
  ClarifaiConcept *concept1 = [[ClarifaiConcept alloc] initWithConceptName:@"dogg"];
  concept1.score = 0;
  img.concepts = @[concept1];
  [_app addInputs:@[img] completion:^(NSArray<ClarifaiInput *> *inputs, NSError *error) {
    assert(error == nil);
    ClarifaiInput *input = inputs[0];
    _runningImageID = input.inputID;
    XCTAssert(input.concepts[0].score == 0);
    [future setResult:@(YES)];
  }];
  [future getResult];
}

- (void)testAddConceptsToInput {
  CAIFuture *future = [[CAIFuture alloc] init];
  [self testAddInputs];
  ClarifaiConcept *concept = [[ClarifaiConcept alloc] initWithConceptName:@"cat"];
  [_app addConcepts:@[concept] forInputWithID:_runningImageID completion:^(ClarifaiInput *input, NSError *error) {
    assert(error == nil);
    bool cat = NO;
    for (ClarifaiConcept *concept in input.concepts) {
      if ([concept.conceptID  isEqualToString: @"cat"]) {
        cat = YES;
      }
    }
    XCTAssert(cat);
    [future setResult:@(YES)];
  }];
  [future getResult];
}

- (void)testDeleteConceptsFromInput {
  CAIFuture *future = [[CAIFuture alloc] init];
  [self testAddConceptsToInput];
  ClarifaiConcept *concept = [[ClarifaiConcept alloc] initWithConceptName:@"cat"];
  [_app deleteConcepts:@[concept] forInputWithID:_runningImageID completion:^(ClarifaiInput *input, NSError *error) {
    assert(error == nil);
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

- (void)testGetInputs {
  CAIFuture *future = [[CAIFuture alloc] init];
  [_app getInputsOnPage:1 pageSize:30 completion:^(NSArray<ClarifaiInput *> *inputs, NSError *error) {
    assert(error == nil);
    [future setResult:@(YES)];
  }];
  [future getResult];
}

- (void)testGetInputByID {
  CAIFuture *future = [[CAIFuture alloc] init];
  [self testAddInputs];
  [_app getInput:_runningImageID completion:^(ClarifaiInput *input, NSError *error) {
    assert(error == nil);
    XCTAssert([_runningImageID isEqualToString:input.inputID]);
    [future setResult:@(YES)];
  }];
  
  [future getResult];
}

- (void)testGetInputStatus {
  CAIFuture *future = [[CAIFuture alloc] init];
  [_app getInputsStatus:^(int numProcessed, int numToProcess, int errors, NSError *error) {
    assert(error == nil);
    [future setResult:@(YES)];
  }];
  
  [future getResult];
}

- (void)testSearchByImageURL {
  CAIFuture *future = [[CAIFuture alloc] init];
  ClarifaiImage *image = [[ClarifaiImage alloc] initWithURL:@"http://i.imgur.com/HEoT5xR.png"];
  ClarifaiSearchTerm *searchTerm = [[ClarifaiSearchTerm alloc] initWithSearchItem:image isInput:YES];
  [_app search:@[searchTerm] page:@1 perPage:@20 completion:^(NSArray<ClarifaiSearchResult *> *outputs, NSError *error) {
    assert(error == nil);
    [future setResult:@(YES)];
  }];
  [future getResult];
}

- (void)testSearchByConcept {
  CAIFuture *future = [[CAIFuture alloc] init];
  ClarifaiConcept *concept1 = [[ClarifaiConcept alloc] initWithConceptName:@"ai_2nvg6rJ6"];
  ClarifaiSearchTerm *searchTerm = [[ClarifaiSearchTerm alloc] initWithSearchItem:concept1 isInput:YES];
  [_app search:@[searchTerm] page:@1 perPage:@20 completion:^(NSArray<ClarifaiSearchResult *> *outputs, NSError *error) {
    assert(error == nil);
    [future setResult:@(YES)];
  }];
  [future getResult];
}

- (void)testSearchVisuallyByInputIDWithCrop {
  CAIFuture *future = [[CAIFuture alloc] init];
  ClarifaiImage *image = [[ClarifaiImage alloc] initWithURL:@"http://i.imgur.com/HEoT5xR.png"];
  image.inputID = @"b448e3be6938480db260ef7115b6ad8f";
  image.crop = CGRectMake(.2, .3, .7, .8);
  ClarifaiSearchTerm *searchTerm = [[ClarifaiSearchTerm alloc] initWithSearchItem:image isInput:YES];
  [_app search:@[searchTerm] page:@1 perPage:@20 completion:^(NSArray<ClarifaiSearchResult *> *outputs, NSError *error) {
    assert(error == nil);
    [future setResult:@(YES)];
  }];
  [future getResult];
}

- (void)testSearchInputsByImageURL {
  CAIFuture *future = [[CAIFuture alloc] init];
  ClarifaiImage *image = [[ClarifaiImage alloc] initWithURL:@"http://i.imgur.com/HEoT5xR.png"];
  ClarifaiSearchTerm *searchTerm = [[ClarifaiSearchTerm alloc] initWithSearchItem:image isInput:YES];
  [_app search:@[searchTerm] page:@1 perPage:@20 completion:^(NSArray<ClarifaiSearchResult *> *outputs, NSError *error) {
    assert(error == nil);
    [future setResult:@(YES)];
  }];
  [future getResult];
}

- (void)testSearchInputsAndOutputsByConcept {
  CAIFuture *future = [[CAIFuture alloc] init];
  ClarifaiConcept *concept1 = [[ClarifaiConcept alloc] initWithConceptName:@"test_candelabra"];
  ClarifaiConcept *concept2 = [[ClarifaiConcept alloc] initWithConceptName:@"test_menorah"];
  ClarifaiSearchTerm *searchTerm1 = [[ClarifaiSearchTerm alloc] initWithSearchItem:concept1 isInput:YES];
  ClarifaiSearchTerm *searchTerm2 = [[ClarifaiSearchTerm alloc] initWithSearchItem:concept2 isInput:NO];
  [_app search:@[searchTerm1, searchTerm2] page:@1 perPage:@20 completion:^(NSArray<ClarifaiSearchResult *> *outputs, NSError *error) {
    assert(error == nil);
    [future setResult:@(YES)];
  }];
  [future getResult];
}

- (void)testDeleteInputByID {
  CAIFuture *future = [[CAIFuture alloc] init];
  [self testAddInputs];
  [_app deleteInput:_runningImageID completion:^(NSError *error) {
    assert(error == nil);
    [_app getInput:_runningImageID completion:^(ClarifaiInput *input, NSError *error) {
      //should be error if input was properly deleted.
      XCTAssert(error != nil);
      [future setResult:@(YES)];
    }];
  }];
  
  [future getResult];
}

- (void)testDeleteInputByIDList {
  CAIFuture *future = [[CAIFuture alloc] init];
  [self testAddInputs];
  ClarifaiInput *input = [[ClarifaiInput alloc] init];
  input.inputID = _runningImageID;
  [_app deleteInputsByIDList:@[input] completion:^(NSError *error) {
    assert(error == nil);
    [_app getInput:_runningImageID completion:^(ClarifaiInput *input, NSError *error) {
      //should be error if input was properly deleted.
      XCTAssert(error != nil);
      [future setResult:@(YES)];
    }];
  }];
  
  [future getResult];
}

- (void)testGetConcepts {
  CAIFuture *future = [[CAIFuture alloc] init];
  [_app getConceptsOnPage:1 pageSize:30 completion:^(NSArray<ClarifaiConcept *> *concepts, NSError *error) {
    assert(error == nil);
    [future setResult:@(YES)];
  }];
  [future getResult];
}

- (void)testAddConcepts {
  NSString *conceptName = [self randomString]; //uses different name on each run (no way to delete free floating concepts).
  [self addConcept:conceptName completion:^(NSArray<ClarifaiConcept *> *concepts, NSError *error) {
  }];
}

- (void)addConcept:(NSString *)conceptName completion:(ClarifaiConceptsCompletion) completion {
  CAIFuture *future = [[CAIFuture alloc] init];
  ClarifaiConcept *concept1 = [[ClarifaiConcept alloc] initWithConceptName: conceptName];
  _runningConceptID = concept1.conceptID;
  [_app addConcepts:@[concept1] completion:^(NSArray<ClarifaiConcept *> *concepts, NSError *error) {
    assert(error == nil);
    XCTAssert([conceptName isEqualToString:concepts[0].conceptID]);
    completion(concepts,error);
    [future setResult:@(YES)];
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

- (void)testAddConceptsToModel {
  CAIFuture *future = [[CAIFuture alloc] init];
  ClarifaiConcept *concept = [[ClarifaiConcept alloc] initWithConceptName:@"burf"];
  ClarifaiImage *image = [[ClarifaiImage alloc] initWithURL:@"https://samples.clarifai.com/metro-north.jpg" andConcepts:@[@"burf"]];
  NSString *modelID = @"b06ced930c784b2fa59b8e1d90551201";
  __weak ClarifaiApp *app = _app;
  [app addInputs:@[image] completion:^(NSArray<ClarifaiInput *> *inputs, NSError *error) {
    assert(error == nil);
    [app addConcepts:@[concept] toModelWithID:modelID completion:^(ClarifaiModel *model, NSError *error) {
      assert(error == nil);
      [app getModelByID:modelID completion:^(ClarifaiModel *model, NSError *error) {
        assert(error == nil);
        [future setResult:@(YES)];
      }];
    }];
  }];
  [future getResult];
  
}

- (void)testAddAndRemoveConceptFromModel {
  CAIFuture *future = [[CAIFuture alloc] init];
  ClarifaiConcept *concept = [[ClarifaiConcept alloc] initWithConceptName:@"burf"];
  __weak ClarifaiApp *app = _app;
  
  [_app addConcepts:@[concept] toModelWithID:@"b06ced930c784b2fa59b8e1d90551201" completion:^(ClarifaiModel *model, NSError *error) {
    assert(error == nil);
    [app deleteConcepts:@[concept] fromModelWithID:@"b06ced930c784b2fa59b8e1d90551201" completion:^(ClarifaiModel *model, NSError *error) {
      assert(error == nil);
      [future setResult:@YES];
    }];
  }];
  [future getResult];
}

- (void)testCreateModel {
  CAIFuture *future = [[CAIFuture alloc] init];
  NSString *modelName = @"burfgerz";
  ClarifaiConcept *concept = [[ClarifaiConcept alloc] initWithConceptName:@"bunz"];
//  [_app addConcepts:@[concept] completion:^(NSArray<ClarifaiConcept *> *concepts, NSError *error) { //UNCOMMENT ON FIRST RUN TO CREATE BUNZ CONCEPT, after that it'll be fine.
//    assert(error == nil);
    [_app createModel:@[concept] name:modelName conceptsMutuallyExclusive:NO closedEnvironment:NO completion:^(ClarifaiModel *model, NSError *error) {
      XCTAssert(error == nil);
      XCTAssert([modelName isEqualToString:model.name]);
      [future setResult:@(YES)];
    }];
 // }];
  
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

- (void)testDeleteAllModels {
  CAIFuture *future = [[CAIFuture alloc] init];
  [self testGetModelsOnPage];
  [_app deleteAllModels:^(NSError *error) {
    assert(error == nil);
    [_app getModelByID:_runningModelID completion:^(ClarifaiModel *model, NSError *error) {
      //should be error if model was properly deleted.
      XCTAssert(error != nil);
      [future setResult:@(YES)];
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
    [future setResult:@(YES)];

  }];
  [future getResult];
}

- (void)testTrainModel {
  CAIFuture *future = [[CAIFuture alloc] init];
  [_app getModels:1 resultsPerPage:20 completion:^(NSArray<ClarifaiModel *> *models, NSError *error) {
    ClarifaiModel *model = models[0];
    [model train:^(ClarifaiModel *model, NSError *error) {
      assert(error == nil);
      [future setResult:@(YES)];
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
    assert(model != nil);
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
    assert(model != nil);
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
    assert(model != nil);
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
    assert(model != nil);
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
    assert(model != nil);
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
    if (error) {
      NSLog(@"error: %@", error);
    } else {
      [model predictOnImages:@[image] completion:^(NSArray<ClarifaiSearchResult *> *outputs, NSError *error) {
        if (error) {
          NSLog(@"error: %@", error);
        } else {
          NSLog(@"outputs: %@", outputs);
          [future setResult:@(YES)];
        }
      }];
    }
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
    assert(error == nil);
    XCTAssert([conceptName isEqualToString:concepts[0].conceptID]);
    [future setResult:@(YES)];
  }];
}

@end









