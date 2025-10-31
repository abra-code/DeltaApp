#!/bin/sh

self_dir=$(/usr/bin/dirname "$0")

app_to_sign="$1"
if test -z "$app_to_sign"; then
	echo "error: a path to app must be provided"
	exit 1
fi

# full path
app_to_sign=$(/bin/realpath "$app_to_sign")

app_id=$(/usr/bin/defaults read "$app_to_sign/Contents/Info.plist" CFBundleIdentifier)
if test "$?" != "0"; then
	echo "error: could not obtain bundle identifier for app at: $app_to_sign"
	exit 1
fi

echo "/usr/bin/codesign --deep --verbose --force --options runtime --entitlements $self_dir/OMCApplet.entitlements --timestamp --identifier $app_id --sign T9NM2ZLDTY $app_to_sign"
/usr/bin/codesign --deep --verbose --force --options runtime --entitlements "$self_dir/OMCApplet.entitlements" --timestamp --identifier "$app_id" --sign "T9NM2ZLDTY" "$app_to_sign"

echo ""
echo "Verifying codesigned app:"
echo "-------------------------"
codesign -dv --verbose=4 "$app_to_sign"
echo "-------------------------"

