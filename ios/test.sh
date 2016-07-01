set -e

cd ScreenShareAccPackKit/

pod install
xcodebuild -workspace "OTScreenShareAccPackKit.xcworkspace" -scheme "OTScreenShareKitBundle" -sdk "iphonesimulator9.3"
xcodebuild clean test -workspace "OTScreenShareAccPackKit.xcworkspace" -scheme "OTScreenShareKitTests" -sdk "iphonesimulator9.3" -destination "OS=9.3,name=iPhone 6 Plus" -configuration Debug

pod cache clean --all
pod spec lint OTScreenShareKit.podspec --use-libraries --allow-warnings --verbose
