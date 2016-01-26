//
//  Credentials.swift
//  ClarifaiApiDemo
//

import Foundation


// IMPORTANT NOTE: you should replace the clarifaiClientID and clarifaiClientSecret values below
// with your own. You can obtain these at https://developer.clarifai.com/applications -- the
// defaults are shared credentials that will stop working once their quota is reached.
// 
// Also, if you're committing your code to a public repo, be careful not to check in your
// credentials -- we're including these here so you can get started out of the box, but this is
// generally a bad practice.
let clarifaiClientID = "CUnWfeKR9C2FyBvjLZwuumEBDztv_gqzw4TukmD3"
let clarifaiClientSecret = "KvqSM_ZoChUr1DEDsYYG1QpfXPzY-ECS9XfeGj9L"


@objc class Credentials : NSObject {
  class func clientID() -> String { return clarifaiClientID }
  class func clientSecret() -> String { return clarifaiClientSecret }
}
