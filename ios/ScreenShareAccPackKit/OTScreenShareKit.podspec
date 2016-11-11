Pod::Spec.new do |s|
  s.name             = "OTScreenShareKit"
  s.version          = "1.1.6"
  s.summary          = "OpenTok Screensharing with Annotations Accelerator Pack enables users to share their screens between mobile or browser-based devices."

  s.description      = "This document describes how to use the OpenTok Screensharing with Annotations Accelerator Pack for iOS. Through the exploration of the OpenTok Screensharing with Annotations Sample App, you will learn best practices for screensharing on an iOS mobile device."

  s.homepage         = "https://tokbox.com/"
  s.license          = 'MIT'
  s.author           = { "Lucas Huang" => "lucas@tokbox.com" }
  s.source           = { :git => "https://github.com/opentok/screen-sharing-acc-pack.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/tokbox/'

  s.ios.deployment_target = '8.0'

  s.source_files = 'ios/ScreenShareAccPackKit/OTScreenShareKit/ScreenShare/**/*'

  s.public_header_files = 'ios/ScreenShareAccPackKit/OTScreenShareKit/ScreenShare/OTScreenShareKit.h', 
    'ios/ScreenShareAccPackKit/OTScreenShareKit/ScreenShare/OTScreenSharer.h'

  s.dependency 'OTAcceleratorPackUtil'
end
