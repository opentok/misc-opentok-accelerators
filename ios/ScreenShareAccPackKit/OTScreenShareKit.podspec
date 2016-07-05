#
# Be sure to run `pod lib lint LHToolbar.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "OTScreenShareKit"
  s.version          = "1.0.1"
  s.summary          = "The OpenTok Screensharing with Annotations Accelerator Pack provides functionality you can add to your OpenTok applications that enables users to share their screens between mobile or browser-based devices."

  s.description      = "This document describes how to use the OpenTok Screensharing with Annotations Accelerator Pack for iOS. Through the exploration of the OpenTok Screensharing with Annotations Sample App, you will learn best practices for screensharing on an iOS mobile device."

  s.homepage         = "https://tokbox.com/"
  s.license          = 'MIT'
  s.author           = { "Lucas Huang" => "lucas@tokbox.com" }
  s.source           = { :git => "https://github.com/opentok/screensharing-annotation-acc-pack.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/tokbox/'

  s.ios.deployment_target = '8.0'

  s.source_files = 'ios/ScreenShareAccPackKit/OTScreenShareKit/**/*'

  s.public_header_files = 'ios/ScreenShareAccPackKit/OTScreenShareKit/ScreenShare/OTScreenShareKit.h', 
    'ios/ScreenShareAccPackKit/OTScreenShareKit/ScreenShare/OTScreenSharer.h', 

  s.dependency 'OTAcceleratorPackUtil'
  s.dependency 'OTAnnotationKit'
end
