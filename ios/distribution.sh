# configurate
set -e
cd AnnotationAccPackKit/

# install cocoapods
pod cache clean --all
pod install

# run distribution script
WORKSPACE_NAME="OTAnnotationAccPackKit.xcworkspace"
SCHEME_NAME="Distribution"

xcodebuild -workspace "${WORKSPACE_NAME}" -scheme "${SCHEME_NAME}"
