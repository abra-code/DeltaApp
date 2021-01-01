#!/bin/sh

dialog="$OMC_OMC_SUPPORT_PATH/omc_dialog_control"

# restore dialog state from prefs

orig_dir=$(/usr/bin/defaults read com.abracode.Delta "orig_dir")
if [ "$?" -eq "0" ] && [ -n "$orig_dir" ]; then
	"$dialog" "$OMC_NIB_DLG_GUID" 1 "$orig_dir"
fi

new_dir=$(/usr/bin/defaults read com.abracode.Delta "new_dir")
if [ "$?" -eq "0" ] && [ -n "$new_dir" ]; then
	"$dialog" "$OMC_NIB_DLG_GUID" 2 "$new_dir"
fi

mode=$(/usr/bin/defaults read com.abracode.Delta "mode")
if [ "$?" -eq "0" ] && [ -n "$mode" ]; then
	"$dialog" "$OMC_NIB_DLG_GUID" 3 "$mode"
	if [ "$mode" == "delta" ]; then
		"$dialog" "$OMC_NIB_DLG_GUID" 4 omc_enable
	else
		"$dialog" "$OMC_NIB_DLG_GUID" 4 omc_disable
	fi
fi

delta=$(/usr/bin/defaults read com.abracode.Delta "delta")
if [ "$?" -eq "0" ] && [ -n "$delta" ]; then
	"$dialog" "$OMC_NIB_DLG_GUID" 4 "$delta"
fi

post_compare_app=$(/usr/bin/defaults read com.abracode.Delta "app")
if [ "$?" -eq "0" ] && [ -n "$post_compare_app" ]; then
	"$dialog" "$OMC_NIB_DLG_GUID" 5 "$post_compare_app"
fi

