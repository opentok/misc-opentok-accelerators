set -e

cd AnnotationAccPackKit/

pod cache clean --all
pod install
xcodebuild clean test -workspace "OTAnnotationAccPackKit.xcworkspace" -scheme "OTAnnotationKitTests" -sdk "iphonesimulator10.0" -destination "OS=10.0,name=iPhone 6 Plus" -configuration Debug

pod spec lint OTAnnotationKit.podspec --use-libraries --allow-warnings --verbose
