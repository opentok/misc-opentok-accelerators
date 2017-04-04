Pod::Spec.new do |s|
  s.name             = "OTAnnotationKit"
  s.version          = "2.0.0-beta7"
  s.summary          = "OpenTok Annotations Accelerator Pack enables users to annotate their screens."

  s.description      = "This document describes how to use the OpenTok Annotations Accelerator Pack for iOS. Through the exploration of the OpenTok Annotations Sample App, you will learn best practices for annotating on an iOS mobile device."

  s.homepage         = "https://tokbox.com/"
  s.license          = 'MIT'
  s.author           = { "Lucas Huang" => "lucas@tokbox.com" }
  s.source           = { :git => "https://github.com/opentok/annotation-acc-pack.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/tokbox/'

  s.ios.deployment_target = '9.0'

  s.source_files = 'ios/AnnotationAccPackKit/OTAnnotationKit/**/*'

  s.resource_bundles = {
    'OTAnnotationKitBundle' => ['ios/AnnotationAccPackKit/OTAnnotationKitBundle/**/*']
  }
  
  s.dependency 'LHToolbar', '1.3.0-beta'
  s.dependency 'OTAcceleratorCore'
  s.deprecated_in_favor_of = 'OTAnnotationAccelerator'
end
