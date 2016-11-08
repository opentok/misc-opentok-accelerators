set -e

task="$1"

# relocate
cd TextChatAccPackKit/

# install cocoapods
pod cache clean --all
pod install
xcodebuild -workspace "OTTextChatAccPackKit.xcworkspace" -scheme "OTTextChatKitBundle" -sdk "iphonesimulator10.0"
xcodebuild clean test -workspace "OTTextChatAccPackKit.xcworkspace" -scheme "OTTextChatKitTests" -sdk "iphonesimulator10.0" -destination "OS=10.0,name=iPhone 6 Plus" -configuration Debug

# validate cocoapods submission
pod spec lint OTTextChatKit.podspec --use-libraries --allow-warnings --verbose

# cd Documentation/
# xcodebuild -project "Documentation.xcodeproj" -scheme "AppleDoc"

#Run UI tests
if [ "$task" == "-ui" ]; then
        cd ../OneToOneTextChatSample
        xcodebuild -workspace OneToOneTextChatSample.xcworkspace -scheme OneToOneTextChatSample -sdk iphonesimulator10.0 -configuration Debug -derivedDataPath build
        cd ../OneToOneTextChatSampleUITests/
        python TextChatUITest.py '../OneToOneTextChatSample/build/Build/Products/Debug-iphonesimulator/OneToOneTextChatSample.app' -platform 'iOS' -platformVersion '10.0' -deviceName 'iPhone 6s Plus' -bundleId 'com.tokbox.OneToOneTextChatSample'
fi
