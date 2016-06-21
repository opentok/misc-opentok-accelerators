set -e

cd TextChatSample/

xcodebuild -workspace "TextChatSample.xcworkspace" -scheme "TextChatKitBundle" -sdk "iphonesimulator9.3"
xcodebuild clean test -workspace "TextChatSample.xcworkspace" -scheme "TextChatSampleTests" -sdk "iphonesimulator9.3" -destination "OS=9.0,name=iPhone 6 Plus" -configuration Debug
