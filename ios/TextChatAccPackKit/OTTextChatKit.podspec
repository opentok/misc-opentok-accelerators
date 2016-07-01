#
# Be sure to run `pod lib lint LHToolbar.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "OTTextChatKit"
  s.version          = "1.0.2"
  s.summary          = "The OpenTok Text Chat Accelerator Pack provides functionality you can add to your OpenTok applications that enables users to exchange text messages between mobile or browser-based devices."

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

  s.public_header_files = 'ios/TextChatAccPackKit/OTTextChatKit/OTTextChatKit.h', 
    'ios/TextChatAccPackKit/OTTextChatKit/OTTextChatUICustomizator/OTTextChatUICustomizator.h',
    'ios/TextChatAccPackKit/OTTextChatKit/OTTextChatView/OTTextChatView.h', 
    'ios/TextChatAccPackKit/OTTextChatKit/OTTextMessage/OTTextMessage.h'
  s.dependency 'OTAcceleratorPackUtil'
end
