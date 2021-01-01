#!/bin/sh

dialog="$OMC_OMC_SUPPORT_PATH/omc_dialog_control"
mode_popup_choice="$OMC_NIB_DIALOG_CONTROL_3_VALUE"

if [ "$mode_popup_choice" == "delta" ]; then
	"$dialog" "$OMC_NIB_DLG_GUID" 4 omc_enable
	"$dialog" "$OMC_NIB_DLG_GUID" 4 omc_select
else
	"$dialog" "$OMC_NIB_DLG_GUID" 4 omc_disable
fi
