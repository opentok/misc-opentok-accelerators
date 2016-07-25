# configurate
set -e
cd TextChatAccPackKit/

# install cocoapods
pod cache clean --all
pod install

# run distribution script
WORKSPACE_NAME="OTTextChatAccPackKit.xcworkspace"
SCHEME_NAME="Distribution"

xcodebuild -workspace "${WORKSPACE_NAME}" -scheme "${SCHEME_NAME}"
