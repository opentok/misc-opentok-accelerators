Pod::Spec.new do |s|
  s.name             = "OTAnnotationKit"
  s.version          = "1.0.0"
  s.summary          = "OpenTok Annotations Accelerator Pack enables users to annotate their screens."

  s.description      = "This document describes how to use the OpenTok Annotations Accelerator Pack for iOS. Through the exploration of the OpenTok Annotations Sample App, you will learn best practices for annotating on an iOS mobile device."

  s.homepage         = "https://tokbox.com/"
  s.license          = 'MIT'
  s.author           = { "Lucas Huang" => "lucas@tokbox.com" }
  s.source           = { :git => "https://github.com/opentok/annotation-acc-pack.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/tokbox/'

  s.ios.deployment_target = '8.0'

  s.source_files = 'ios/AnnotationAccPackKit/OTAnnotationKit/**/*'
  
  s.resource_bundles = {
    'OTAnnotationKitBundle' => ['ios/AnnotationAccPackKit/OTAnnotationKitBundle/**/*']
  }

  s.public_header_files = 'ios/AnnotationAccPackKit/OTAnnotationKit/OTAnnotationKit.h', 
    'ios/AnnotationAccPackKit/OTAnnotationKit/OTAnnotationNative/OTAnnotatable.h', 
    'ios/AnnotationAccPackKit/OTAnnotationKit/OTAnnotationNative/OTAnnotationDataManager.h', 
    'ios/AnnotationAccPackKit/OTAnnotationKit/OTAnnotationNative/OTAnnotationPath.h',
    'ios/AnnotationAccPackKit/OTAnnotationKit/OTAnnotationNative/OTAnnotationPoint.h',
    'ios/AnnotationAccPackKit/OTAnnotationKit/OTAnnotationNative/OTAnnotationTextView.h',
    'ios/AnnotationAccPackKit/OTAnnotationKit/OTAnnotationNative/OTAnnotationView.h',
    'ios/AnnotationAccPackKit/OTAnnotationKit/OTAnnotationUI/OTAnnotationScrollView.h',
    'ios/AnnotationAccPackKit/OTAnnotationKit/OTAnnotationUI/OTFullScreenAnnotationViewController.h',
    'ios/AnnotationAccPackKit/OTAnnotationKit/OTAnnotationUI/Toolbar/OTAnnotationToolbarView.h'

  s.dependency 'LHToolbar', '1.2.1-beta'
  s.dependency 'OTKAnalytics', '1.0.0'
  s.dependency 'OTAcceleratorPackUtil', '1.0.0'
end
