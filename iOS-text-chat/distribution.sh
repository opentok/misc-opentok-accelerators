set -e

cd TextChatSample/
xcodebuild -workspace "TextChatSample.xcworkspace" -scheme "Build Framework"
 
# then, the TextChatKit.zip containing TextChatKit.framework, TextChatKitBundle.bundle and docs will sit at current directory