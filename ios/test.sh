set -e

cd TextChatAccPackKit/

pod cache clean --all
pod install
xcodebuild -workspace "OTTextChatAccPackKit.xcworkspace" -scheme "OTTextChatKitBundle" -sdk "iphonesimulator9.3"
xcodebuild clean test -workspace "OTTextChatAccPackKit.xcworkspace" -scheme "OTTextChatKitTests" -sdk "iphonesimulator9.3" -destination "OS=9.3,name=iPhone 6 Plus" -configuration Debug

pod spec lint OTTextChatKit.podspec --use-libraries --allow-warnings --verbose

# cd Documentation/
# xcodebuild -project "Documentation.xcodeproj" -scheme "AppleDoc"