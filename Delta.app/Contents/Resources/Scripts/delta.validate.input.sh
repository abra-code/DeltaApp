#!/bin/sh

dialog="$OMC_OMC_SUPPORT_PATH/omc_dialog_control"
#plister="$OMC_OMC_SUPPORT_PATH/plister"
#filt="$OMC_OMC_SUPPORT_PATH/filt"
#pasteboard="$OMC_OMC_SUPPORT_PATH/pasteboard"
#next_command="$OMC_OMC_SUPPORT_PATH/omc_next_command"

orig_dir="$OMC_NIB_DIALOG_CONTROL_1_VALUE"
new_dir="$OMC_NIB_DIALOG_CONTROL_2_VALUE"
mode_popup_choice="$OMC_NIB_DIALOG_CONTROL_3_VALUE"
size_delta="$OMC_NIB_DIALOG_CONTROL_4_VALUE"

# NSPathControl default value is "/" but let's not allow comparing the root dirs and treat it as unspecified  
if [ "$orig_dir" = "/" ]; then
	"$OMC_OMC_SUPPORT_PATH/alert" --level stop --title "Incorrect Input" "Please specify the \"original\" folder by dragging a folder from Finder to the first path control in the dialog."
	"$dialog" "$OMC_NIB_DLG_GUID" 1 omc_select
	exit 1
fi

if [ "$new_dir" = "/" ]; then
	"$OMC_OMC_SUPPORT_PATH/alert" --level stop --title "Incorrect Input" "Please specify the \"modified\" folder by dragging a folder from Finder to the second path control in the dialog."
	"$dialog" "$OMC_NIB_DLG_GUID" 2 omc_select
	exit 1
fi


if [ ! -d "$orig_dir" ]; then
	error_msg="Specified \"original\" folder does not exist: $orig_dir"
	if [ -e "$orig_dir" ]; then
		error_msg="Specified \"original\" item is not a folder: $orig_dir"
	fi
	"$OMC_OMC_SUPPORT_PATH/alert" --level stop --title "Incorrect Input" "$error_msg"
	"$dialog" "$OMC_NIB_DLG_GUID" 1 omc_select
	exit 1
fi

if [ ! -d "$new_dir" ]; then
	error_msg="Specified \"modified\" folder does not exist: $new_dir"
	if [ -e "$new_dir" ]; then
		error_msg="Specified \"modified\" item is not a folder: $new_dir"
	fi
	"$OMC_OMC_SUPPORT_PATH/alert" --level stop --title "Incorrect Input" "$error_msg"
	"$dialog" "$OMC_NIB_DLG_GUID" 2 omc_select
	exit 1
fi
