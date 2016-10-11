set -e

cd ScreenShareAccPackKit/

pod cache clean --all
pod install
xcodebuild clean test -workspace "OTScreenShareAccPackKit.xcworkspace" -scheme "OTScreenShareKitTests" -sdk "iphonesimulator10.0" -destination "OS=10.0,name=iPhone 6 Plus" -configuration Debug

pod spec lint OTScreenShareKit.podspec --use-libraries --allow-warnings --verbose
