//
//  ClarifaiSearchTerm.m
//  Pods
//
//  Created by John Sloan on 3/7/17.
//
//

#import "ClarifaiSearchTerm.h"
#import "ClarifaiInput.h"
#import "ClarifaiConcept.h"
#import "ClarifaiImage.h"

@interface ClarifaiSearchTerm()

@property BOOL isInputsTerm;

// Properties for Inputs Term
@property (strong, nonatomic) NSString *imageURL;
@property (strong, nonatomic) NSString *inputID;
@property (strong, nonatomic) ClarifaiGeo *geo;
@property (strong, nonatomic) NSDictionary *metadata;
@property (strong, nonatomic) ClarifaiConcept *concept;

// Properties for Outputs Term
@property (strong,nonatomic) NSString *visualSearchImageURL;
@property (strong,nonatomic) NSString *visualSearchInputID;
@property (strong,nonatomic) NSData *visualSearchImageData;
@property (strong,nonatomic) ClarifaiCrop *imageCrop;
@property (strong,nonatomic) ClarifaiConcept *predictedConcept;

@end


@implementation ClarifaiSearchTerm

#pragma mark Search outputs

+ (ClarifaiSearchTerm *) searchVisuallyWithImageURL:(NSString *)imageURL {
  ClarifaiSearchTerm *term = [[ClarifaiSearchTerm alloc] init];
  term.visualSearchImageURL = imageURL;
  term.isInputsTerm = NO;
  return term;
}

+ (ClarifaiSearchTerm *) searchVisuallyWithImageURL:(NSString *)imageURL andCrop:(ClarifaiCrop *)imageCrop {
  ClarifaiSearchTerm *term = [[ClarifaiSearchTerm alloc] init];
  term.visualSearchImageURL = imageURL;
  term.imageCrop = imageCrop;
  term.isInputsTerm = NO;
  return term;
}

+ (ClarifaiSearchTerm *) searchVisuallyWithInputID:(NSString *)inputID {
  ClarifaiSearchTerm *term = [[ClarifaiSearchTerm alloc] init];
  term.visualSearchInputID = inputID;
  term.isInputsTerm = NO;
  return term;
}

+ (ClarifaiSearchTerm *) searchVisuallyWithImageData:(NSData *)imageData {
  ClarifaiSearchTerm *term = [[ClarifaiSearchTerm alloc] init];
  term.visualSearchImageData = imageData;
  term.isInputsTerm = NO;
  return term;
}

+ (ClarifaiSearchTerm *) searchVisuallyWithUIImage:(UIImage *)image {
  ClarifaiSearchTerm *term = [[ClarifaiSearchTerm alloc] init];
  term.visualSearchImageData = UIImageJPEGRepresentation(image, 0.9);
  term.isInputsTerm = NO;
  return term;
}

+ (ClarifaiSearchTerm *) searchByPredictedConcept:(ClarifaiConcept *)concept {
  ClarifaiSearchTerm *term = [[ClarifaiSearchTerm alloc] init];
  term.predictedConcept = concept;
  term.isInputsTerm = NO;
  return term;
}

#pragma mark Search inputs

+ (ClarifaiSearchTerm *)searchInputsWithImageURL:(NSString *)imageURL {
  ClarifaiSearchTerm *term = [[ClarifaiSearchTerm alloc] init];
  term.imageURL = imageURL;
  term.isInputsTerm = YES;
  return term;
}

+ (ClarifaiSearchTerm *)searchInputsWithInputID:(NSString *)inputID {
  ClarifaiSearchTerm *term = [[ClarifaiSearchTerm alloc] init];
  term.inputID = inputID;
  term.isInputsTerm = YES;
  return term;
}

+ (ClarifaiSearchTerm *)searchInputsWithGeoFilter:(ClarifaiGeo *)geo {
  ClarifaiSearchTerm *term = [[ClarifaiSearchTerm alloc] init];
  term.geo = geo;
  term.isInputsTerm = YES;
  return term;
}

+ (ClarifaiSearchTerm *)searchInputsWithMetadata:(NSDictionary *)metadata {
  ClarifaiSearchTerm *term = [[ClarifaiSearchTerm alloc] init];
  term.metadata = metadata;
  term.isInputsTerm = YES;
  return term;
}

+ (ClarifaiSearchTerm *)searchInputsByConcept:(ClarifaiConcept *)concept {
  ClarifaiSearchTerm *term = [[ClarifaiSearchTerm alloc] init];
  term.concept = concept;
  term.isInputsTerm = YES;
  return term;
}

- (ClarifaiSearchTerm *)addImageCrop:(ClarifaiCrop *)imageCrop {
  if (!_isInputsTerm && (_visualSearchInputID || _visualSearchImageURL || _visualSearchImageData)) {
    _imageCrop = imageCrop;
  } else {
    NSLog(@"Cannot add image crop to an Inputs search.");
  }
  return self;
}

- (instancetype)initWithSearchItem:(id)searchItem isInput:(BOOL)isInput {
  self = [super init];
  if (self) {
    _isInputsTerm = isInput;
    if (isInput) {
      // Setup inputs search term
      if ([searchItem isKindOfClass:[ClarifaiInput class]]) {
        ClarifaiInput *inputItem = (ClarifaiInput *)searchItem;
        if (inputItem.inputID) {
          _inputID = inputItem.inputID;
        }
        
        if (inputItem.metadata) {
          _metadata = inputItem.metadata;
        }
      }
      if ([searchItem isKindOfClass:[ClarifaiImage class]]) {
        ClarifaiImage *imageItem = (ClarifaiImage *)searchItem;
        
        if (imageItem.mediaURL) {
          _imageURL = imageItem.mediaURL;
        }
        
      } else if ([searchItem isKindOfClass:[ClarifaiConcept class]]) {
        ClarifaiConcept *conceptItem = (ClarifaiConcept *)searchItem;
        _concept = conceptItem;
      }
    } else {
      // Setup outputs search term
      if ([searchItem isKindOfClass:[ClarifaiInput class]]) {
        ClarifaiInput *inputItem = (ClarifaiInput *)searchItem;
        if (inputItem.inputID) {
          _visualSearchInputID = inputItem.inputID;
        }
      }
      
      if ([searchItem isKindOfClass:[ClarifaiImage class]]) {
        ClarifaiImage *imageItem = (ClarifaiImage *)searchItem;

        if (imageItem.mediaURL) {
          _visualSearchImageURL = imageItem.mediaURL;
        }
        
        if (imageItem.mediaData) {
          _visualSearchImageData = imageItem.mediaData;
        }
        
        if (imageItem.crop) {
          _imageCrop = imageItem.crop;
        }
      } else if ([searchItem isKindOfClass:[ClarifaiConcept class]]) {
        ClarifaiConcept *conceptItem = (ClarifaiConcept *)searchItem;
        _predictedConcept = conceptItem;
      }
    }
  }
  return self;
}

- (NSDictionary *)searchTermAsDictionary {
  if (_isInputsTerm) {
    // Convert Search term for inputs search
    NSMutableDictionary *formattedInputTerm = [NSMutableDictionary dictionary];
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
    
    if (_geo) {
      dataDict[@"geo"] = [_geo geoFilterAsDictionary];
    }
    
    if (_metadata) {
      dataDict[@"metadata"] = _metadata;
    }
    
    if (_inputID) {
      formattedInputTerm[@"id"] = _inputID;
      dataDict[@"image"] = @{};
    }
    
    if (_imageURL) {
      dataDict[@"image"] = @{@"url":_imageURL};
    }
    
    if (_concept) {
      dataDict[@"concepts"] = @[@{@"name":_concept.conceptName, @"value":[NSNumber numberWithFloat:_concept.score]}];
    }
    
    formattedInputTerm[@"data"] = dataDict;
    return @{@"input": formattedInputTerm};
  } else {
    // Convert Search term for outputs search
    NSMutableDictionary *formattedOutputsTerm = [NSMutableDictionary dictionary];
    NSMutableDictionary *inputDict = [NSMutableDictionary dictionary];
    NSMutableDictionary *inputDataDict = [NSMutableDictionary dictionary];
    NSMutableDictionary *outputDataDict = [NSMutableDictionary dictionary];
    
    if (_predictedConcept) {
      outputDataDict[@"concepts"] = @[@{@"name":_predictedConcept.conceptName}];
    }
    
    if (_visualSearchInputID) {
      inputDict[@"id"] = _visualSearchInputID;
      inputDataDict[@"image"] = [NSMutableDictionary dictionary];
    }
    
    if (_visualSearchImageURL) {
      NSMutableDictionary *imageDict = [NSMutableDictionary dictionary];
      imageDict[@"url"] = _visualSearchImageURL;
      inputDataDict[@"image"] = imageDict;
    }
    
    if (_visualSearchImageData) {
      // Overwrites image dictionary as you cannot search with both image data + url in same search term.
      NSMutableDictionary *imageDict = [NSMutableDictionary dictionary];
      NSString *dataString = [_visualSearchImageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
      imageDict[@"base64"] = dataString;
      inputDataDict[@"image"] = imageDict;
    }
    
    if (_imageCrop) {
      NSArray *cropArray = @[@(_imageCrop.top),
                             @(_imageCrop.left),
                             @(_imageCrop.bottom),
                             @(_imageCrop.right)];
      if (inputDataDict[@"image"] != nil) {
        inputDataDict[@"image"][@"crop"] = cropArray;
      } else {
        //can't add crop if no image data, url or input ID is given!
      }
    }
    
    // add input data dictionary to input if used.
    if ([inputDataDict.allKeys count] > 0) {
      inputDict[@"data"] = inputDataDict;
    }
    
    // add input dictionary to search term only if used.
    if ([inputDict.allKeys count] > 0) {
      formattedOutputsTerm[@"input"] = inputDict;
    }
    
    // add output data dictionary (containing a concept) if used.
    if ([outputDataDict.allKeys count] > 0) {
      formattedOutputsTerm[@"data"] = outputDataDict;
    }
    
    return @{@"output": formattedOutputsTerm};
  }
}

@end
