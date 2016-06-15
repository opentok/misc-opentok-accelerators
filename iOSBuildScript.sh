set -e

cd iOS-text-chat/TextChatSample/
xcodebuild -workspace "TextChatSample.xcworkspace" -scheme "Build Framework"
cd ../OneToOneTextChatSample/
 
# then, the TextChatKit.zip containing TextChatKit.framework, TextChatKitBundle.bundle and docs will sit at current directory
# "iOS-text-chat/OneToOneTextChatSample/"