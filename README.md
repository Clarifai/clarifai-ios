# clarifai-ios-starter
This is a simple project to get you started using the Clarifai API in iOS apps. It includes usage
of the API in both Swift and Objective-C. Full Clarifai API documentation can be found at
[developer.clarifai.com](http://developer.clarifai.com/).

<img src="http://i.imgur.com/nJPz9gc.jpg" width="200">


## Building and Running

[![Build Status](https://travis-ci.org/Clarifai/clarifai-ios-starter.svg?branch=master)](https://travis-ci.org/Clarifai/clarifai-ios-starter)

To build this project, you need [Xcode 7](https://developer.apple.com/xcode/download/) and [CocoaPods](http://cocoapods.org/). To build and run:

1. Install dependencies and generate workspace.
  ```
  pod install
  ```

2. Open the workspace in Xcode
  ```
  open ClarifaiApiDemo.xcworkspace
  ```

3. Go to [developer.clarifai.com/applications](https://developer.clarifai.com/applications), click
   on your application, then copy the "Client ID" and "Client Secret" values (if you don't already
   have an account or application, you'll need to create them first).

   Replace the values of `clarifaiClientID` and `clarifaiClientSecret` in
   [Credentials.swift](ClarifaiApiDemo/Credentials.swift) with the ones you copied.

4. Press the "Play" button in the toolbar to build, install, and run the app.


## Swift
[SwiftRecognitionViewController](ClarifaiApiDemo/SwiftRecognitionViewController.swift) is a simple
view controller written in Swift. It prompts the user to select a photo from their photo library
and sends it to the Clarifai API for tagging.


## Objective-C
[RecognitionViewController](ClarifaiApiDemo/RecognitionViewController.m) is a simple view controller
written in Objective-C. It prompts the user to select a photo from their photo library and sends it
to the Clarifai API for tagging. The Objective-C version is *not* enabled by default. To use it,
you need to:

1. Open Main.storyboard in XCode
2. Select "Clarifai Scene"
3. In the Identity Inspector, change the custom class to `RecognitionViewController`


## Next steps
Feel free to use this project as a base for building your app. Alternately, you can copy
[ClarifaiClient.h](ClarifaiApiDemo/ClarifaiClient.h) and
[ClarifaiClient.m](ClarifaiApiDemo/ClarifaiClient.m) into a your own project and use them to make
calls to Clarifai. Have fun!
