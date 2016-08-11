set -e

cd AnnotationAccPackKit/

pod cache clean --all
pod install
xcodebuild clean test -workspace "OTAnnotationAccPackKit.xcworkspace" -scheme "OTAnnotationKitTests" -sdk "iphonesimulator9.3" -destination "OS=9.3,name=iPhone 6 Plus" -configuration Debug
if [${PIPESTATUS[0]} == true]; then
  exit ${PIPESTATUS[0]}
fi

pod spec lint OTAnnotationKit.podspec --use-libraries --allow-warnings --verbose
