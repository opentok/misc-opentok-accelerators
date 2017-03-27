set -e

task="$1"
args="$#"

cd ScreensharingAccPackKit

#Create local properties to find Android SDK
if [ ! -e "local.properties" ]
then
        echo sdk.dir=$ANDROID_HOME >> local.properties
fi

#Ensure gradle wraper is properly set
gradle wrapper

#Perform all actions
if [ "$task" == "-f" ]; then
        ./gradlew build
        ./gradlew  test
        ./gradlew ZipBundleRelease
        exit 0
fi

#Build project
if [ "$task" == "-b" ]; then
        ./gradlew build
        exit 0
fi

#Run unit tests
if [ "$task" == "-t" ]; then
        ./gradlew  test
        exit 0
fi

#Run android tests
if [ "$task" == "-at" ]; then
    i=0
    argv=""
    for var in "$@"
    do
          params[$i]=$var
          i=$[$i+1]
    done
    for ((i = 1; i <= $args; i++)); do
          argv="$argv ${params[$i]}"
    done
    adb uninstall com.tokbox.android.accpack.screensharing.test
    ./gradlew assembleAndroidTest
    adb install -r screensharing-acc-pack-kit/build/outputs/apk/opentok-screensharing-annotations-debug-androidTest-unaligned.apk
    adb shell am instrument -e package com.tokbox.android.accpack.screensharing.test $argv -w com.tokbox.android.accpack.screensharing.test/com.tokbox.android.accpack.screensharing.testbase.TestRunner
    exit 0
fi

#Create zip file with binary and doc
if [ "$task" == "-d" ]; then
        ./gradlew ZipBundleRelease
        exit 0
fi

echo Invalid parameters, please use ‘-b’ to build, ‘-t’ to run unit tests, ‘-at’ to run android tests, ‘-d’ to create zip file with binary and doc or ‘-f’ to perform all actions.
exit 1
