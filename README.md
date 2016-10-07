# Clarifai Objective-C Client
A client for iOS apps using the Clarifai v2 API.

* Sign up for a free developer account at: https://developer.clarifai.com/signup/
* Read the developer guide at: https://developer.clarifai.com/guide-v2/
* Read the full Objective-C docs at: https://sdk.clarifai.com/iOS/docs-2.0.0/masterTOC.html

## Installation
### CocoaPods
The client will be up on Cocoapods soon. For now, download the repo and add the following to your Podfile to locally install it into your project:

```
pod 'Clarifai', :path => '/path-to-downloaded-repo-folder/'
```

## Getting Started

1. Create a new XCode project, or use a current one.

2. Add Clarifai to podfile and generate workspace.
    ```
    pod 'Clarifai', :path => '/path-to-downloaded-repo-folder/'
    ```
    ```
    pod install
    ```

3. Import ClarifaiApp.h and any other classes you need.
    ```
    #import ClarifaiApp.h
    ```

4. Go to [developer.clarifai.com/applications](https://developer.clarifai.com/applications), click
on your application, then copy the "Client ID" and "Client Secret" values (if you don't already
have an account or application, you'll need to sign up first).

5. Create your Clarifai application in your project.
    ```
    ClarifaiApp *app = [[ClarifaiApp alloc] initWithAppID:@"" appSecret:@""];
    ```
6. That's it! Explore the API docs and guide.

## Documentation

The most recent docs can currently be found [here](https://sdk.clarifai.com/iOS/docs-2.0.0/masterTOC.html). 

## Example Project

There is a simple demo included in the repo to help you get started. To build this project, you need [Xcode 8](https://developer.apple.com/xcode/download/) and [CocoaPods](http://cocoapods.org/). To build and run:

1. Install dependencies and generate workspace from inside the Example folder.
    ```
    pod install
    ```

2. Open the workspace in Xcode
    ```
    open Clarifai.xcworkspace
    ```

3. Go to [developer.clarifai.com/applications](https://developer.clarifai.com/applications), click
   on your application, then copy the "Client ID" and "Client Secret" values (if you don't already
   have an account or application, you'll need to sign up first).

   Add the values of your Client ID and Client Secret to the recognizeImage method in RecognitionViewController.m.

4. Press the "Play" button in the toolbar to build, install, and run the app.
