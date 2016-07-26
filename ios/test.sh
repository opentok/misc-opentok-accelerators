set -e

cd ScreenShareAccPackKit/

pod cache clean --all
pod install
xcodebuild clean test -workspace "OTScreenShareAccPackKit.xcworkspace" -scheme "OTScreenShareKitTests" -sdk "iphonesimulator9.3" -destination "OS=9.3,name=iPhone 6 Plus" -configuration Debug && exit ${PIPESTATUS[0]}

pod spec lint OTScreenShareKit.podspec --use-libraries --allow-warnings --verbose
