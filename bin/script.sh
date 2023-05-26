#!/bin/bash

# Accept the path to versions.js as an argument
VERSIONS_FILE="$1"


# Read the versions from versions.js
VERSIONS_FILE="versions.js"
ANDROID_VERSION_NAME=$(node -p "require('./$VERSIONS_FILE').androidVersionName")
ANDROID_VERSION_CODE=$(node -p "require('./$VERSIONS_FILE').androidVersionCode")
IOS_VERSION=$(node -p "require('./$VERSIONS_FILE').iosVersion")
IOS_BUILD=$(node -p "require('./$VERSIONS_FILE').iosBuild")

# Process command line arguments
while [[ $# -gt 0 ]]
do
    key="$1"
    case $key in
        -patch)
        # Increment the androidVersionCode and iosBuild
        ANDROID_VERSION_CODE=$((ANDROID_VERSION_CODE + 1))
        IOS_BUILD=$((IOS_BUILD + 1))

        # Increment the version numbers in versions.js
        sed -i '' "s/androidVersionCode: '[0-9]*'/androidVersionCode: '$ANDROID_VERSION_CODE'/" $VERSIONS_FILE
        sed -i '' "s/iosBuild: '[0-9]*'/iosBuild: '$IOS_BUILD'/" $VERSIONS_FILE
        shift
        ;;
        -minor)
        # Increment the androidVersionName and iosVersion (incrementing from the back)
        IFS='.' read -ra ANDROID_VERSION_PARTS <<< "$ANDROID_VERSION_NAME"
        ANDROID_VERSION_PARTS[2]=$((ANDROID_VERSION_PARTS[2] + 1))
        ANDROID_VERSION_NAME="${ANDROID_VERSION_PARTS[0]}.${ANDROID_VERSION_PARTS[1]}.${ANDROID_VERSION_PARTS[2]}"

        IFS='.' read -ra IOS_VERSION_PARTS <<< "$IOS_VERSION"
        IOS_VERSION_PARTS[2]=$((IOS_VERSION_PARTS[2] + 1))
        IOS_VERSION="${IOS_VERSION_PARTS[0]}.${IOS_VERSION_PARTS[1]}.${IOS_VERSION_PARTS[2]}"

        # Update the version numbers in versions.js
        sed -i '' "s/androidVersionName: '[0-9.]*'/androidVersionName: '$ANDROID_VERSION_NAME'/" $VERSIONS_FILE
        sed -i '' "s/iosVersion: '[0-9.]*'/iosVersion: '$IOS_VERSION'/" $VERSIONS_FILE
        shift
        ;;
        -major)
        # Increment the androidVersionName and iosVersion from the start
        IFS='.' read -ra ANDROID_VERSION_PARTS <<< "$ANDROID_VERSION_NAME"
        ANDROID_VERSION_PARTS[0]=$((ANDROID_VERSION_PARTS[0] + 1))
        ANDROID_VERSION_PARTS[1]=0
        ANDROID_VERSION_PARTS[2]=0
        ANDROID_VERSION_NAME="${ANDROID_VERSION_PARTS[0]}.${ANDROID_VERSION_PARTS[1]}.${ANDROID_VERSION_PARTS[2]}"

        IFS='.' read -ra IOS_VERSION_PARTS <<< "$IOS_VERSION"
        IOS_VERSION_PARTS[0]=$((IOS_VERSION_PARTS[0] + 1))
        IOS_VERSION_PARTS[1]=0
        IOS_VERSION_PARTS[2]=0
        IOS_VERSION="${IOS_VERSION_PARTS[0]}.${IOS_VERSION_PARTS[1]}.${IOS_VERSION_PARTS[2]}"

        # Update the version numbers in versions.js
        sed -i '' "s/androidVersionName: '[0-9.]*'/androidVersionName: '$ANDROID_VERSION_NAME'/" $VERSIONS_FILE
        sed -i '' "s/iosVersion: '[0-9.]*'/iosVersion: '$IOS_VERSION'/" $VERSIONS_FILE
        shift
        ;;
        *)
        # Unknown flag, skip
        shift
        ;;
    esac
done

# Update Android version
ANDROID_GRADLE_FILE="android/app/build.gradle"
sed -i '' "s/versionCode [0-9]*/versionCode $ANDROID_VERSION_CODE/" $ANDROID_GRADLE_FILE
sed -i '' "s/versionName \".*\"/versionName \"$ANDROID_VERSION_NAME\"/" $ANDROID_GRADLE_FILE

# Update iOS version
IOS_INFO_PLIST_FILE="ios/Farmo/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $IOS_VERSION" $IOS_INFO_PLIST_FILE
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $IOS_BUILD" $IOS_INFO_PLIST_FILE

# Print the updated versions
echo "Android version: $ANDROID_VERSION_NAME (Code: $ANDROID_VERSION_CODE)"
echo "iOS version: $IOS_VERSION (Build: $IOS_BUILD)"
