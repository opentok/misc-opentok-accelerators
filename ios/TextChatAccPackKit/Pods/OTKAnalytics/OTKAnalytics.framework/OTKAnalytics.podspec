#
# Be sure to run `pod lib lint LHToolbar.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "OTKAnalytics"
  s.version          = "1.0.0"
  s.summary          = "Vertical Solutions Logging."

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = "As an OpenTok Vertical Solutions team member, I want to be able to know the use of each different solutions project, so I have to register what is the solution used by the partners/developers.

Eg: Log the use of the Text-chat component on Android by the partner xxxx.

As an OpenTok Vertical Solutions team member, I want to be able to know the use of the different features of each OpenTok Vertical Solution, so I have to register what are the actions fired by the partners/developers.

Eg: Get the number of the sent messages, using the Text-chat component on Android, by the partner xxxx in the last 2 days."

  s.homepage         = "https://tokbox.com/"
  s.license          = {:type => "Commercial", :text => "https://tokbox.com/support/tos"}
  s.author           = { "Lucas Huang" => "lucas@tokbox.com" }
  s.source           = { :http => "https://www.dropbox.com/s/sflfvdu4x5mprkf/SolutionsLogging.zip?dl=0"}
  s.vendored_frameworks = "OTKAnalytics.framework"
  s.social_media_url = 'https://twitter.com/tokbox/'

  s.ios.deployment_target = '8.0'
end
