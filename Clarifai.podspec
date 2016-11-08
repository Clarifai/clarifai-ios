Pod::Spec.new do |s|
  s.name             = 'Clarifai'
  s.version          = '2.1.0'
  s.summary          = 'Clarifai API client for Objective-C.'
 
  s.homepage         = 'https://github.com/Clarifai'
  s.license          = { :type => 'Apache', :file => 'LICENSE' }
  s.author           = { 'John Sloan' => 'johnsloan@clarifai.com', 'Jack Rogers' => 'jack@clarifai.com' }

  s.platform         = :ios, '8.0'
  s.source = {:git => 'https://github.com/Clarifai/clarifai-ios.git', :tag => s.version.to_s}
  s.source_files = 'Clarifai/Classes/*'
  
  s.dependency 'AFNetworking', '~> 2.0'
end