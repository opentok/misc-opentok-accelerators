Pod::Spec.new do |s|
  s.name             = "OTAcceleratorPackUtil"
  s.version          = "1.0.0"
  s.summary          = "Common Accelerator Session Pack Version 1.0."

  s.description      = "The Common Accelerator Session Pack is required whenever you use any of the OpenTok accelerators. The Common Accelerator Session Pack is a common layer that permits all accelerators and samples to share the same OpenTok session. The accelerator packs and sample app access the OpenTok session through the Common Accelerator Session Pack layer, which allows them to share a single OpenTok session.

On the Android and iOS mobile platforms, when you try to set a listener (Android) or delegate (iOS), it is not normally possible to set multiple listeners or delegates for the same event. For example, on these mobile platforms you can only set one OpenTok signal listener. The Common Accelerator Session Pack, however, allows you to set up several listeners for the same event."

  s.homepage         = "https://github.com/opentok/acc-pack-common"
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { "Lucas Huang" => "lucas@tokbox.com" }
  s.source           = { :git => "https://github.com/opentok/acc-pack-common.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/tokbox'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'ios/OTAcceleratorPackUtilProject/OTAcceleratorPackUtil/**/*.{h,m}'
  s.public_header_files = 'ios/OTAcceleratorPackUtilProject/OTAcceleratorPackUtil/**/*.{h}'
  s.dependency 'OTKAnalytics', '~> 1.0.0'
  s.dependency 'OpenTok', '~> 2.8.3'
end
