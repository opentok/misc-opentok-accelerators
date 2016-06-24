set -e

cd TextChatAccPackKit/
xcodebuild -workspace "OTTextChatAccPackKit.xcworkspace" -scheme "Distribution"
 
# then, the TextChatKit.zip containing TextChatKit.framework, TextChatKitBundle.bundle and docs will sit at current directory