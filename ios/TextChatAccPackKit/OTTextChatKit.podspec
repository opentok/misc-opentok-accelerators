Pod::Spec.new do |s|
  s.name             = "OTTextChatKit"
  s.version          = "2.0.0-beta10"
  s.summary          = "OpenTok Text Chat Accelerator Pack enables text messages between mobile or browser-based devices."

  s.description      = "This document describes how to use the OpenTok Text Chat Accelerator Pack for iOS. Through the exploration of the One to One Text Chat Sample Application, you will learn best practices for exchanging text messages on an iOS mobile device."

  s.homepage         = "https://tokbox.com/"
  s.license          = 'MIT'
  s.author           = { "Lucas Huang" => "lucas@tokbox.com" }
  s.source           = { :git => "https://github.com/opentok/textchat-acc-pack.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/tokbox/'

  s.ios.deployment_target = '8.0'

  s.source_files = 'ios/TextChatAccPackKit/OTTextChatKit/**/*'
  
  s.resource_bundles = {
    'OTTextChatKitBundle' => ['ios/TextChatAccPackKit/OTTextChatKitBundle/**/*']
  }

  s.dependency 'OTAcceleratorPackUtil', '~> 2.0.0beta2'
end
