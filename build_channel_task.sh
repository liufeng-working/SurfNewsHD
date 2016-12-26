CHANNEL_NAME=$1
CHANNEL_ID=$2

if [ "$CHANNEL_NAME" = "" ]; then
echo "error: no channel name found"
exit 1
fi

if [ "$CHANNEL_ID" = "" ]; then
echo "error: no channel id found"
exit 1
fi

TARGET_DIR=JB_CHANNELS	#生成app的目录
TARGET_DIR=`pwd`/$TARGET_DIR
APP_NAME=`xcodebuild -scheme "SurfNews-JAILBREAK" -showBuildSettings | grep TARGET_NAME`
APP_NAME=${APP_NAME:18}	#从索引18开始截取

xcodebuild -scheme "SurfNews-JAILBREAK" -configuration Release GCC_PREPROCESSOR_DEFINITIONS='$GCC_PREPROCESSOR_DEFINITIONS JB_CHANNEL_ID=@\"'$CHANNEL_ID'\"' CONFIGURATION_BUILD_DIR=$TARGET_DIR

if test $? -eq 0
     then
        echo "Build Succeeded"
     else
        echo "=================Build Failed================="
        exit 1
     fi

xcrun -sdk iphoneos PackageApplication -v "$TARGET_DIR/$APP_NAME.app" -o "$TARGET_DIR/$APP_NAME-$CHANNEL_NAME-$CHANNEL_ID.ipa"
