Pod::Spec.new do |s|
  s.name             = "OTScreenShareKit"
  s.version          = "2.0.6"
  s.deprecated_in_favor_of = 'OTAcceleratorCore'
  s.summary          = "OpenTok Screensharing with Annotations Accelerator Pack enables users to share their screens between mobile or browser-based devices."

  s.description      = "This document describes how to use the OpenTok Screensharing with Annotations Accelerator Pack for iOS. Through the exploration of the OpenTok Screensharing with Annotations Sample App, you will learn best practices for screensharing on an iOS mobile device."

  s.homepage         = "https://tokbox.com/"
  s.license          = 'MIT'
  s.author           = { "Lucas Huang" => "lucas@tokbox.com" }
  s.source           = { :git => "https://github.com/opentok/screen-sharing-acc-pack.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/tokbox/'

  s.ios.deployment_target = '8.0'

  s.source_files = 'ios/ScreenShareAccPackKit/OTScreenShareKit/**/*'

  s.dependency 'OTAcceleratorPackUtil'
end
