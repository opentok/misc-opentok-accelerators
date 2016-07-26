set -e

cd AnnotationAccPackKit/

pod cache clean --all
pod install
xcodebuild -workspace "OTAnnotationAccPackKit.xcworkspace" -scheme "OTAnnotationKitBundle" -sdk "iphonesimulator9.3"
xcodebuild clean test -workspace "OTAnnotationAccPackKit.xcworkspace" -scheme "OTAnnotationKitTests" -sdk "iphonesimulator9.3" -destination "OS=9.3,name=iPhone 6 Plus" -configuration Debug && exit ${PIPESTATUS[0]}

pod spec lint OTAnnotationKit.podspec --use-libraries --allow-warnings --verbose
