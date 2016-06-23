set -e

cd TextChatAccPackKit/

xcodebuild -workspace "TextChatAccPackKit.xcworkspace" -scheme "TextChatKitBundle" -sdk "iphonesimulator9.3"
xcodebuild clean test -workspace "TextChatAccPackKit.xcworkspace" -scheme "TextChatKitTests" -sdk "iphonesimulator9.3" -destination "OS=9.0,name=iPhone 6 Plus" -configuration Debug
