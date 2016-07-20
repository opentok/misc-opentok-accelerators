# configurate
set -e
cd ScreenShareAccPackKit/

# install cocoapods
pod cache clean --all
pod install

# run distribution script
WORKSPACE_NAME="OTScreenShareAccPackKit.xcworkspace"
SCHEME_NAME="Distribution"

xcodebuild -workspace "${WORKSPACE_NAME}" -scheme "${SCHEME_NAME}"
