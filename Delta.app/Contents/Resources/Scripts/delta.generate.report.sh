#!/bin/sh

dialog="$OMC_OMC_SUPPORT_PATH/omc_dialog_control"
#plister="$OMC_OMC_SUPPORT_PATH/plister"
#filt="$OMC_OMC_SUPPORT_PATH/filt"
pasteboard="$OMC_OMC_SUPPORT_PATH/pasteboard"
#next_command="$OMC_OMC_SUPPORT_PATH/omc_next_command"

orig_dir="$OMC_NIB_DIALOG_CONTROL_1_VALUE"
new_dir="$OMC_NIB_DIALOG_CONTROL_2_VALUE"
mode_popup_choice="$OMC_NIB_DIALOG_CONTROL_3_VALUE"
size_delta="$OMC_NIB_DIALOG_CONTROL_4_VALUE"
post_compare_app="$OMC_NIB_DIALOG_CONTROL_5_VALUE"

diff_mode="$mode_popup_choice"
if [ "$mode_popup_choice" = "delta" ]; then
	diff_mode="$size_delta"
	if [ -z "$diff_mode" ]; then
		diff_mode = "0"
	fi
fi

/usr/bin/defaults write com.abracode.Delta "orig_dir" "$orig_dir"
/usr/bin/defaults write com.abracode.Delta "new_dir" "$new_dir"
/usr/bin/defaults write com.abracode.Delta "mode" "$mode_popup_choice"
/usr/bin/defaults write com.abracode.Delta "delta" "$size_delta"
/usr/bin/defaults write com.abracode.Delta "app" "$post_compare_app"

script_dir="$OMC_APP_BUNDLE_PATH/Contents/Resources/Scripts"

# the applet obtained this path upfront by presenting "Save As" dialog 
output_tsv=$("$pasteboard" "DELTA_OUT_TSV" get);
"$pasteboard" "DELTA_OUT_TSV" set ""

"$script_dir/CompareDirsWithReplay.bash" "$orig_dir" "$new_dir" "$diff_mode" > "$output_tsv"

status="$?"

if [ "$status" -ne "0" ]; then
	"$OMC_OMC_SUPPORT_PATH/alert" --level stop --title "Delta Error" "Unexpected error occurred"
	exit "$status"
fi

if [ "$post_compare_app" = "Finder" ]; then
	/usr/bin/osascript "$script_dir/RevealInFinder.scpt" "$output_tsv"
elif [ -n "$post_compare_app" ] && [ "$post_compare_app" != "None" ]; then
	/usr/bin/open -a "$post_compare_app" "$output_tsv"
fi
